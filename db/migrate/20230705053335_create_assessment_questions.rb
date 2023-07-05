class CreateAssessmentQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :assessment_questions do |t|
      t.string :question
      t.string :correct_option
      t.string :level

      t.timestamps
    end
  end
end
