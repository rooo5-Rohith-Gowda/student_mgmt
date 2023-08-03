require 'rails_helper'

RSpec.describe Admin::AssessmentQuestionsController, type: :controller do
  let(:admin_user) { create(:admin_user) }

  before do
    sign_in(admin_user)
  end

  describe 'POST #import_csv' do
    type = 'text/csv'
    it 'imports CSV file and creates assessment questions' do
      csv_file = fixture_file_upload('Untitled spreadsheet - Sheet1 (24).csv', type)

      post :import_csv, params: { assessment_question: { csv_file: csv_file } }

      expect(response).to redirect_to(admin_assessment_questions_path)
    end


    it 'skips rows with blank question_text or options_text' do

        csv_file = fixture_file_upload('Untitled spreadsheet - Sheet1 (23) copy.csv', type)
  
        post :import_csv, params: { assessment_question: { csv_file: csv_file } }
  
        expect(flash[:alert]).to eq("Invalid question or options in the row, and the row was skipped.")
    end

    it 'skips rows with invalid options_text' do

        csv_file = fixture_file_upload('Untitled spreadsheet - Sheet1 (23).csv', type)
  
        post :import_csv, params: { assessment_question: { csv_file: csv_file } }
  
        expect(flash[:alert]).to eq("Invalid options for a question and row was skipped.")
    end

    it 'skips rows with blank question_text or options_text' do
        csv_data = "question,options\n,Option A, Option B\nWhat is 2 + 2?,\n"
  
        csv_file = Tempfile.new(['sample_data', '.csv'])
        csv_file.write(csv_data)
        csv_file.rewind
  
        post :import_csv, params: { assessment_question: { csv_file: csv_file } }
  
        expect(flash[:alert]).to eq("Invalid File Format. Please upload a valid CSV file with the correct data structure.")
    end

    # it "redirects to new_import_csv_admin_assessment_questions_path" do
    #     post :import_csv, params: { assessment_question: { csv_file: nil } }
    #     expect(flash[:alert]).to eq("No CSV file was uploaded.")
    # end

  end
end
