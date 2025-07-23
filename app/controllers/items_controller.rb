class ItemsController < ApplicationController
  before_action :force_basic_auth, only: [:index]
  before_action :authenticate_user!, only: [:new, :create, :edit, :destroy]
  before_action :set_item, only: [:edit, :show, :update, :destroy]

  def index
    @items = Item.order('created_at DESC')
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    return unless current_user != @item.user || @item.order.present?

    redirect_to root_path
  end

  def update
    if @item.update(item_params)
      redirect_to item_path(@item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user == @item.user
      @item.destroy
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  private

  def force_basic_auth
    Rails.logger.info '=== ItemsController Force Basic Auth ==='
    Rails.logger.info "Authorization header: #{request.headers['HTTP_AUTHORIZATION']}"

    unless request.headers['HTTP_AUTHORIZATION']
      Rails.logger.info 'No authorization header - sending 401'
      response.headers['WWW-Authenticate'] = 'Basic realm="FURIMA"'
      render plain: 'Authentication required', status: :unauthorized
      return
    end

    # Basic認証のヘッダーを解析
    auth_header = request.headers['HTTP_AUTHORIZATION']
    if auth_header.start_with?('Basic ')
      encoded_credentials = auth_header.split(' ').last
      decoded_credentials = Base64.decode64(encoded_credentials)
      username, password = decoded_credentials.split(':')

      Rails.logger.info "Parsed credentials - username: #{username}, password: #{password}"

      if username == 'admin' && password == 'password123'
        Rails.logger.info 'Authentication successful'
        return
      else
        Rails.logger.info 'Authentication failed'
        response.headers['WWW-Authenticate'] = 'Basic realm="FURIMA"'
        render plain: 'Authentication failed', status: :unauthorized
        return
      end
    end

    Rails.logger.info 'Invalid authorization header format'
    response.headers['WWW-Authenticate'] = 'Basic realm="FURIMA"'
    render plain: 'Invalid authentication format', status: :unauthorized
  end

  def item_params
    params.require(:item).permit(:name, :description, :category_id, :condition_id, :delivery_fee_id, :prefecture_id,
                                 :shipping_day_id, :price, :image).merge(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
