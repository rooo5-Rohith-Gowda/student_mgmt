ActiveAdmin.register AssessmentQuestion do
  permit_params :question, :correct_option, :level, :assessment_id
  
  form do |f|
    f.inputs "AssessmentQuestion Details" do
      f.input :question
      f.input :assessment_id, as: :select, collection: Assessment.pluck(:name, :id)
      f.input :correct_option
      f.input :level
    end
    f.actions
  end

  index do 
    selectable_column
    id_column
    column :question
    column :correct_option
    column :level
    column :assessment do |assessment_question|
      Assessment.find(assessment_question.assessment_id).name
    end
    actions
  end
end
