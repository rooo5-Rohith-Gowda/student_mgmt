ActiveAdmin.register Qualification do
  permit_params :name
  
  index do 
    selectable_column
    id_column
    column :name
    actions
  end

  form do |f|
    f.inputs 'Qualification Details' do
      f.input :name
    end
    f.inputs 'CSV Import' do
      f.input :csv_file, as: :file, input_html: { multiple: false }
    end
    f.actions
  end

  controller do
    def create
      if params[:qualification] && params[:qualification][:csv_file]
        csv_file = params[:qualification][:csv_file]
        if csv_file.present?
          begin
            CSV.foreach(csv_file.path, headers: true) do |row|
              Qualification.create(name: row['name'])
            end
            redirect_to admin_qualifications_path, notice: 'CSV file imported successfully.'
          rescue StandardError => e
            redirect_to new_admin_qualification_path, alert: "Error importing CSV file: #{e.message}"
          end
        else
          redirect_to new_admin_qualification_path, alert: 'No CSV file was uploaded.'
        end
      else
        super
      end
    end
  end
end
