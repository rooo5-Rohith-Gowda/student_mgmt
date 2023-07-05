FactoryBot.define do
  factory :academic do
    college_name { Faker::Educator.university }
    career_goals { Faker::Lorem.sentence }
    language { "Kannada, English" }
    other_language { "Hindi" }
    currently_working { Faker::Boolean.boolean }
    specialization { Faker::Lorem.word }
    experiance { Faker::Number.between(from: 1, to: 10).to_s+" years" }
    availability { Faker::Boolean.boolean }
    association :user
    association :interest
    association :qualification
  end
end
