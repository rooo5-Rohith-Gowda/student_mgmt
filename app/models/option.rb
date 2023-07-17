class Option < ApplicationRecord
    belongs_to :assessment_question

    validates :choice, presence: true
    validates :assessment_question_id, presence: true
end
