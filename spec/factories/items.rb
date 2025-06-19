FactoryBot.define do
  factory :item do
    name { '靴' }
    description { '靴です' }
    category_id { 2 }
    condition_id { 2 }
    delivery_fee_id { 2 }
    prefecture_id { 2 }
    shipping_day_id { 2 }
    price { 2000 }
    association :user

    after(:build) do |item|
      item.image.attach(io: File.open('public/images/tekito_images.png'), filename: 'tekito_images.png')
    end
  end
end
