class Option < ApplicationRecord
    belongs_to :assessment_question
  
    validates :choice, presence: true, length: { minimum: 1}
    # validates :assessment_question_id, presence: true
end
