FactoryBot.define do
  factory :assessment_question do
    question { "Faker::Lorem.sentence" }
    correct_option { "Faker::Lorem.word" }
    level { %w[level1 level2].sample }
    association :assessment
  end
end
