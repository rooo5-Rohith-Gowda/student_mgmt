FactoryBot.define do
  factory :user do
    email { Faker::Internet.email}
    password { Faker::Internet.password(min_length: 8) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    full_phone_number { "+917204580335" }
    gender { 'male' }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65 ) }
    role { %w[teacher student admin].sample }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }
    address { Faker::Address.full_address}
  end
end