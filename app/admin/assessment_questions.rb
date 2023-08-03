ActiveAdmin.register AssessmentQuestion do
  permit_params :question, :level, :assessment_id, :correct_option, :csv_file, options_attributes: [:id, :choice, :_destroy]

  action_item :import_csv, only: :index do
    link_to 'Import CSV', new_import_csv_admin_assessment_questions_path
  end
  
  collection_action :new_import_csv, method: :get do
    @assessment_question = AssessmentQuestion.new
    render 'admin/assessment_questions/import_csv_form'
  end

  collection_action :import_csv, method: :post do
    if params[:assessment_question] && params[:assessment_question][:csv_file]
      csv_file = params[:assessment_question][:csv_file]
      if csv_file.present?
        begin
          skipped_count = 0
          total_question = 0
  
          CSV.foreach(csv_file.path, headers: true) do |row|
            total_question += 1
            question_text = row['question']
            options_text = row['options']
  
            if question_text.blank? || options_text.blank?
              flash.now[:alert] = "Invalid question or options in the row, and the row was skipped."
              skipped_count += 1
              next
            end
  
            options = options_text.split(',').map(&:strip)
  
            if options.any?(&:blank?) || options_text.end_with?(',') || options_text.starts_with?(',')
              flash.now[:alert] = "Invalid options for a question and row was skipped."
              skipped_count += 1
              next
            end
  
            assessment_params = row.to_h.slice('question', 'level', 'assessment_id')
            assessment_question = AssessmentQuestion.new(assessment_params)
  
            options.each do |option_text|
              assessment_question.options.build(choice: option_text)
            end
  
            if assessment_question.valid?
              assessment_question.save
              puts "Assessment Question Saved: #{assessment_question.inspect}"
            else
              puts "Assessment Question Errors: #{assessment_question.errors.full_messages.join(', ')}"
            end
          end
  
          if skipped_count > 0
            flash[:alert_with_count] = "#{total_question - skipped_count} were added out of #{total_question} questions, #{skipped_count} were skipped due to invalid format."
          else
            flash[:notice] = "CSV file imported successfully."
          end

          redirect_to admin_assessment_questions_path
          
        rescue StandardError => e
          redirect_to new_import_csv_admin_assessment_questions_path, alert: "Invalid File Format. Please upload a valid CSV file with the correct data structure."
        end
      else
        redirect_to new_import_csv_admin_assessment_question_path, alert: 'No CSV file was uploaded.'
      end
    else
      redirect_to new_import_csv_admin_assessemnt_questions_path, alert: 'No CSV file was uploaded.'
    end
  end
  

  form do |f|
    f.inputs "AssessmentQuestion Details" do
      f.input :question
      f.input :assessment_id, as: :select, collection: Assessment.pluck(:name, :id)
      f.input :correct_option, as: :select, collection: f.object.options.pluck(:choice, :id)
      f.input :level
    end
  
    f.inputs "Options" do
      f.has_many :options, allow_destroy: true, heading: false, new_record: 'Add Option' do |option|
        option.input :choice
      end
    end
  
    f.actions
  end

  index do 
    selectable_column
    id_column
    column :question
    column :correct_option do |assessment_question|
      assessment_question.correct_option_choice
    end
    column :level
    column :assessment do |assessment_question|
      Assessment.find(assessment_question.assessment_id).name
    end
    actions
  end

  controller do
    def create
      @assessment_question = AssessmentQuestion.new(permitted_params[:assessment_question])

      if @assessment_question.save
        redirect_to admin_assessment_questions_path, notice: 'Assessment question was successfully created.'
      else
        flash[:error] = @assessment_question.errors.full_messages.join(', ')
        render :new
      end
    end
  end
end
