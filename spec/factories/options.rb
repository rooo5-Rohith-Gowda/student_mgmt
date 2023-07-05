FactoryBot.define do
  factory :option do
    choice { "Faker::Lorem.word" }
    association :assessment_question
  end
end
