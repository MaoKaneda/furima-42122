class OrdersController < ApplicationController
  before_action :set_item, only: [:index, :create]
  before_action :authenticate_user!, only: [:index, :create]

  def index
    if current_user == @item.user || @item.order.present?
      redirect_to root_path
      return
    end

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    @order_address = OrderAddress.new
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
    @item = Item.find(params[:item_id])
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

    charge
  end
end
