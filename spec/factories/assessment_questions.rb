FactoryBot.define do
  factory :assessment_question do
    question { "Faker::Lorem.sentence" }
    correct_option { "Faker::Lorem.word" }
    level { %w[level1 level2].sample }
    association :assessment

    after(:build) do |assessment_question|
      assessment_question.options << build_list(:option, 3, assessment_question: assessment_question)
    end
  end
end
