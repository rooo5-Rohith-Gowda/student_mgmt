class AssessmentQuestion < ApplicationRecord
    belongs_to :assessment
    has_one_attached :csv_file
    has_many :options, dependent: :destroy
    enum level: { level1: "level1", level2: "level2" }
    validates :question, length: {minimum: 1}, presence: true
    validates :level, presence: true
    accepts_nested_attributes_for :options, allow_destroy: true, reject_if: :all_blank

    def correct_option_choice
        correct_option_id = self.correct_option
        option = options.find_by(id: correct_option_id)
        option&.choice
    end
end