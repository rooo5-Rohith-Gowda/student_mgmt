ActiveAdmin.register Academic do

  permit_params :college_name, :interest_id, :qualification_id, :career_goals, :language, :other_language, :currently_working, :specialization, :experiance, :availability, :user_id
  
  form do |f|
    f.inputs "Academic Details" do
      f.input :college_name
      f.input :interest_id, as: :select, collection: Interest.pluck(:name, :id)
      f.input :qualification_id, as: :select, collection: Qualification.pluck(:name, :id)
      f.input :career_goals
      f.input :language
      f.input :other_language
      f.input :currently_working
      f.input :specialization
      f.input :experiance
      f.input :availability
      f.input :user_id, as: :select, collection: User.pluck(:first_name, :id)
    end
    f.actions
  end

  index do 
    selectable_column
    id_column
    column :college_name
    column :interest do |academic|
      Interest.find(academic.interest_id).name
    end
    column :qualification do |academic|
      Qualification.find(academic.qualification_id).name
    end
    column :user do |academic|
      User.find(academic.user_id).email
    end
    actions
  end
end
