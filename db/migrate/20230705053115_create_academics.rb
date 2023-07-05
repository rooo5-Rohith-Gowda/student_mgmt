class CreateAcademics < ActiveRecord::Migration[7.0]
  def change
    create_table :academics do |t|
      t.string :college_name
      t.references :interest, null: false, foreign_key: true
      t.references :qualification, null: false, foreign_key: true
      t.string :career_goals
      t.string :language
      t.string :other_language
      t.boolean :currently_working
      t.string :specialization
      t.string :experiance
      t.boolean :availability
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
