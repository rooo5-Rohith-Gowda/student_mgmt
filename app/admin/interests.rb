ActiveAdmin.register Interest do
  permit_params :name  

  index do 
    selectable_column
    id_column
    column :name
    actions
  end
end
