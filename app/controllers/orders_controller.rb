class OrdersController < ApplicationController
  before_action :set_item, only: [:index, :create]
  before_action :authenticate_user!, only: [:index, :create]

  def index
    if current_user == @item.user || @item.order.present?
      redirect_to root_path
      return
    end

    # 環境変数の確認
    Rails.logger.info '=== gon設定デバッグ ==='
    Rails.logger.info "ENV['PAYJP_PUBLIC_KEY']: #{ENV['PAYJP_PUBLIC_KEY']}"
    Rails.logger.info "ENV['PAYJP_PUBLIC_KEY'].present?: #{ENV['PAYJP_PUBLIC_KEY'].present?}"

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']

    Rails.logger.info "gon.public_key設定後: #{gon.public_key}"
    Rails.logger.info '================================'

    @order_address = OrderAddress.new
  end

  def create
    @order_address = OrderAddress.new(order_params)

    # デバッグ情報を追加
    Rails.logger.info '=== createアクション開始 ==='
    Rails.logger.info "受信パラメータ: #{order_params}"
    Rails.logger.info "OrderAddress valid?: #{@order_address.valid?}"
    Rails.logger.info "OrderAddress errors: #{@order_address.errors.full_messages}" unless @order_address.valid?
    Rails.logger.info '個別エラー詳細:'
    @order_address.errors.each do |attribute, message|
      Rails.logger.info "  #{attribute}: #{message}"
    end
    Rails.logger.info '========================'

    if @order_address.valid?
      begin
        Rails.logger.info '=== 決済処理開始 ==='
        # 決済処理
        charge = pay_item
        Rails.logger.info '=== 決済処理完了 ==='
        Rails.logger.info "chargeオブジェクト: #{charge.class}"
        Rails.logger.info "charge.id: #{charge.id}"
        Rails.logger.info "charge.amount: #{charge.amount}"

        begin
          Rails.logger.info "charge.paid: #{charge.paid}"
          Rails.logger.info "charge.paidの型: #{charge.paid.class}"
          paid_status = charge.paid
        rescue StandardError => e
          Rails.logger.error "charge.paid呼び出しエラー: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          paid_status = false
        end

        if paid_status
          # 決済成功時
          Rails.logger.info '=== 決済成功、保存処理開始 ==='
          Rails.logger.info "保存前のパラメータ: #{order_params}"
          Rails.logger.info "OrderAddress valid?: #{@order_address.valid?}"
          Rails.logger.info "OrderAddress errors: #{@order_address.errors.full_messages}"
          Rails.logger.info 'saveメソッド呼び出し前'

          save_result = @order_address.save
          Rails.logger.info "saveメソッド呼び出し後: #{save_result}"

          if save_result
            Rails.logger.info '=== 保存成功、購入完了 ==='
            redirect_to root_path, notice: '購入が完了しました'
          else
            # 保存に失敗した場合
            Rails.logger.error '=== 決済成功後の保存エラー ==='
            Rails.logger.error "エラーメッセージ: #{@order_address.errors.full_messages}"
            Rails.logger.error "パラメータ: #{order_params}"
            Rails.logger.error '個別エラー:'
            @order_address.errors.each do |attribute, message|
              Rails.logger.error "  #{attribute}: #{message}"
            end
            Rails.logger.error '================================'
            gon.public_key = ENV['PAYJP_PUBLIC_KEY']
            @order_address.errors.add(:base, '購入情報の保存に失敗しました')
            render :index, status: :unprocessable_entity
          end
        else
          # 決済失敗時
          Rails.logger.error '=== 決済失敗 ==='
          Rails.logger.error "charge.paid: #{charge.paid}"
          Rails.logger.error "charge詳細: #{charge.to_json}"
          gon.public_key = ENV['PAYJP_PUBLIC_KEY']
          @order_address.errors.add(:base, '決済に失敗しました')
          render :index, status: :unprocessable_entity
        end
      rescue Payjp::CardError => e
        # カードエラー
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "カードエラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::InvalidRequestError => e
        # 無効なリクエスト
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "無効なリクエスト: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::AuthenticationError => e
        # 認証エラー
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "認証エラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::APIConnectionError => e
        # API接続エラー
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "API接続エラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue Payjp::APIError => e
        # APIエラー
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "APIエラー: #{e.message}")
        render :index, status: :unprocessable_entity
      rescue StandardError => e
        # その他のエラー
        gon.public_key = ENV['PAYJP_PUBLIC_KEY']
        @order_address.errors.add(:base, "予期しないエラーが発生しました: #{e.message}")
        render :index, status: :unprocessable_entity
      end
    else
      # バリデーションエラーの詳細をログに出力
      Rails.logger.error '=== バリデーションエラー詳細 ==='
      Rails.logger.error "エラーメッセージ: #{@order_address.errors.full_messages}"
      Rails.logger.error "パラメータ: #{order_params}"
      Rails.logger.error '個別エラー:'
      @order_address.errors.each do |attribute, message|
        Rails.logger.error "  #{attribute}: #{message}"
      end
      Rails.logger.error '================================'
      gon.public_key = ENV['PAYJP_PUBLIC_KEY']
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def order_params
    params.require(:order_address).permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number).merge(
      user_id: current_user.id, item_id: @item.id, token: params[:token]
    )
  end

  def pay_item
    Rails.logger.info '=== pay_item開始 ==='

    # 環境変数から秘密鍵を取得
    secret_key = ENV['PAYJP_SECRET_KEY']
    raise Payjp::AuthenticationError.new('PAYJP_SECRET_KEYが設定されていません') unless secret_key.present?

    Payjp.api_key = secret_key
    Rails.logger.info 'Payjp.api_key設定完了'

    # トークンの存在確認
    token = order_params[:token]
    Rails.logger.info "トークン: #{token}"
    raise Payjp::InvalidRequestError.new('トークンが提供されていません') unless token.present?

    # 決済処理
    Rails.logger.info "決済処理開始: amount=#{@item.price}, card=#{token}"
    charge = Payjp::Charge.create(
      amount: @item.price,
      card: token,
      currency: 'jpy',
      description: "商品: #{@item.name}",
      metadata: {
        item_id: @item.id,
        user_id: current_user.id
      }
    )

    Rails.logger.info "決済処理完了: Charge ID: #{charge.id}, Amount: #{charge.amount}, Paid: #{charge.paid}"
    Rails.logger.info "Charge詳細: #{charge.to_json}"
    Rails.logger.info '=== pay_item完了 ==='

    charge
  end
end
