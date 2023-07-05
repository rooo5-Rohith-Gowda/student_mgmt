class Option < ApplicationRecord
    belongs_to :assessment_question

    validates :choice, presence: true
end
