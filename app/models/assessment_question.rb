class AssessmentQuestion < ApplicationRecord
    belongs_to :assessment
    has_many :options
    enum level: { level1: "level1", level2: "level2" }
    validates :question, :correct_option, :level, presence: true
end
