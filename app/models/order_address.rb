class OrderAddress
  include ActiveModel::Model
  attr_accessor :postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number, :user_id, :item_id, :token

  validates :postal_code, presence: true, format: { with: /\A[0-9]{3}-[0-9]{4}\z/, message: 'はハイフン(-)を含めて入力してください' }
  validates :prefecture_id, presence: true, numericality: { other_than: 1, message: 'を選択してください' }
  validates :city, presence: true
  validates :house_number, presence: true
  validates :phone_number, presence: true, format: { with: /\A[0-9]{10,11}\z/, message: 'は10桁または11桁の数字で入力してください' }
  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :token, presence: true

  def save
    Rails.logger.info '=== OrderAddress save開始 ==='
    Rails.logger.info "valid?: #{valid?}"
    Rails.logger.info "errors: #{errors.full_messages}" unless valid?
    Rails.logger.info "属性値: postal_code=#{postal_code}, prefecture_id=#{prefecture_id}, city=#{city}, house_number=#{house_number}, phone_number=#{phone_number}, user_id=#{user_id}, item_id=#{item_id}, token=#{token}"

    return false unless valid?

    ActiveRecord::Base.transaction do
      Rails.logger.info "Order作成開始: user_id=#{user_id}, item_id=#{item_id}"
      order = Order.create!(user_id: user_id, item_id: item_id)
      Rails.logger.info "Order作成成功: id=#{order.id}"

      Rails.logger.info "Address作成開始: order_id=#{order.id}"
      Rails.logger.info "Address属性: postal_code=#{postal_code}, prefecture_id=#{prefecture_id}, city=#{city}, house_number=#{house_number}, building_name=#{building_name}, phone_number=#{phone_number}"
      address = Address.create!(
        postal_code: postal_code,
        prefecture_id: prefecture_id.to_i,
        city: city,
        house_number: house_number,
        building_name: building_name,
        phone_number: phone_number,
        order_id: order.id
      )
      Rails.logger.info "Address作成成功: id=#{address.id}"
      Rails.logger.info '=== OrderAddress save完了 ==='
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "OrderAddress保存エラー: #{e.message}"
    Rails.logger.error "Orderエラー: #{e.record.errors.full_messages}" if e.record.is_a?(Order)
    Rails.logger.error "Addressエラー: #{e.record.errors.full_messages}" if e.record.is_a?(Address)
    false
  rescue StandardError => e
    Rails.logger.error "予期しないエラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
