ActiveAdmin.register Option do
  permit_params :choice, :assessment_question_id

  form do |f|
    f.inputs "Options Details" do
      f.input :choice
      f.input :assessment_question_id, as: :select, collection: AssessmentQuestion.pluck(:question, :id)
    end
    f.actions
  end

  index do 
    selectable_column
    id_column
    column :choice
    column :assessment_question do |option|
      AssessmentQuestion.find(option.assessment_question_id).question
    end
    actions
  end
  
end
