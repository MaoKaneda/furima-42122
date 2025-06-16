FactoryBot.define do
  factory :user do
    nickname { Faker::Internet.username }
    email { Faker::Internet.email }
    password { '111aaa' }
    password_confirmation { password }
    last_name { '本田' }
    first_name { 'テスト' }
    last_name_kana { 'ホンダ' }
    first_name_kana { 'テスト' }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end 