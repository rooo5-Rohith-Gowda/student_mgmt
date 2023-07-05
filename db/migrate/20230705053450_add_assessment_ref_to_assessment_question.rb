class AddAssessmentRefToAssessmentQuestion < ActiveRecord::Migration[7.0]
  def change
    add_reference :assessment_questions, :assessment, null: false, foreign_key: true
  end
end
