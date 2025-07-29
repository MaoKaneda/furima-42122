class OrdersController < ApplicationController
  before_action :set_item, only: [:index, :create]
  before_action :authenticate_user!, only: [:index, :create]

  def index
    Rails.logger.info '=== OrdersController#index 開始 ==='
    Rails.logger.info "current_user: #{current_user.inspect}"
    Rails.logger.info "@item: #{@item.inspect}"
    Rails.logger.info "@item.user: #{@item.user.inspect}"

    # ログインチェックはbefore_actionで行われる
    if current_user == @item.user
      Rails.logger.info '自分が出品した商品のためリダイレクト'
      redirect_to root_path, alert: '自分が出品した商品は購入できません'
      return
    end

    if @item.order.present?
      Rails.logger.info '売り切れ商品のためリダイレクト'
      redirect_to root_path, alert: 'この商品は既に売り切れています'
      return
    end

    Rails.logger.info '購入画面を表示開始'

    # gonの設定
    begin
      gon.public_key = ENV['PAYJP_PUBLIC_KEY'] || 'pk_test_dummy_key_for_testing'
      Rails.logger.info "gon.public_key設定完了: #{gon.public_key}"
    rescue StandardError => e
      Rails.logger.error "gon設定でエラー: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to root_path, alert: '購入画面の設定に失敗しました'
      return
    end

    # OrderAddressの初期化
    begin
      @order_address = OrderAddress.new
      Rails.logger.info "OrderAddress初期化完了: #{@order_address.inspect}"
    rescue StandardError => e
      Rails.logger.error "OrderAddress初期化でエラー: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to root_path, alert: '購入情報の初期化に失敗しました'
      return
    end

    Rails.logger.info '購入画面を表示終了'
    Rails.logger.info '=== OrdersController#index 終了 ==='
  rescue StandardError => e
    Rails.logger.error "OrdersController#index でエラーが発生: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: '購入画面の読み込みに失敗しました'
  end

  def create
    @order_address = OrderAddress.new(order_params)

    if @order_address.valid?
      begin
        charge = pay_item
        paid_status = charge.paid

        if paid_status
          save_result = @order_address.save

          if save_result
            redirect_to root_path, notice: '購入が完了しました'
          else
            gon.public_key = ENV['PAYJP_PUBLIC_KEY']
            @order_address.errors.add(:base, '購入情報の保存に失敗しました')
            render :index, status: :unprocessable_entity
          end
        else
          gon.public_key = ENV['PAYJP_PUBLIC_KEY']
          @order_address.errors.add(:base, '決済に失敗しました')
          render :index, status: :unprocessable_entity
        end
      rescue Payjp::CardError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "カードエラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::InvalidRequestError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "無効なリクエスト: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::AuthenticationError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "認証エラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::APIConnectionError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "API接続エラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::APIError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "APIエラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue StandardError => e
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "予期しないエラーが発生しました: #{e.message}")
        render :index, status: :unprocessable_entity
      end
    else
      gon.public_key = ENV['PAYJP_PUBLIC_KEY']
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_item
    Rails.logger.info '=== set_item 開始 ==='
    Rails.logger.info "params[:item_id]: #{params[:item_id]}"
    @item = Item.find(params[:item_id])
    Rails.logger.info "@item: #{@item.inspect}"
    Rails.logger.info '=== set_item 終了 ==='
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "商品が見つかりません: #{e.message}"
    redirect_to root_path, alert: '商品が見つかりませんでした'
  rescue StandardError => e
    Rails.logger.error "set_item でエラーが発生: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: '商品情報の取得に失敗しました'
  end

  def order_params
    params.require(:order_address).permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number).merge(
      user_id: current_user.id, item_id: @item.id, token: params[:token]
    )
  end

  def pay_item
    secret_key = ENV['PAYJP_SECRET_KEY']
    raise Payjp::AuthenticationError.new('PAYJP_SECRET_KEYが設定されていません') unless secret_key.present?

    Payjp.api_key = secret_key

    token = order_params[:token]
    raise Payjp::InvalidRequestError.new('トークンが提供されていません') unless token.present?

    Payjp::Charge.create(
      amount: @item.price,
      card: token,
      currency: 'jpy',
      description: "商品: #{@item.name}",
      metadata: {
        item_id: @item.id,
        user_id: current_user.id
      }
    )
  end
end
