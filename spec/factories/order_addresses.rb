FactoryBot.define do
  factory :order_address do
    postal_code { '000-0000' }
    prefecture_id { 2 }
    city { '札幌市' }
    house_number { '1-1' }
    building_name { '札幌ハイツ' }
    phone_number { '08012345678' }
    token { 'tok_abcdefghijk00000000000000000' }
  end
end
