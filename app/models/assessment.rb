class Assessment < ApplicationRecord
    validates :name, presence: true
    has_many :assessment_questions
end
