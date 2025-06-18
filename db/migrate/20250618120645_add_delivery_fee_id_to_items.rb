class AddDeliveryFeeIdToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :delivery_fee_id, :integer
  end
end
