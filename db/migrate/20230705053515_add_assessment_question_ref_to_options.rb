class AddAssessmentQuestionRefToOptions < ActiveRecord::Migration[7.0]
  def change
    add_reference :options, :assessment_question, null: false, foreign_key: true
  end
end
