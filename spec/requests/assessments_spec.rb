require 'rails_helper'

RSpec.describe AssessmentsController, type: :controller do

  let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
  let(:student_user) { FactoryBot.create(:user, role: 'student') }
  let(:token_admin) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }
  let(:token_student) { JWT.encode({ sub: student_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }
  let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
      let(:token_teacher) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

  include ActionMailer::TestHelper
  describe "GET /index" do
    context 'when user is admin' do
      before do
        request.headers['token'] = token_admin
      end

      it 'returns all the assessment if present' do
        assessment = create(:assessment)
        assessment1 = create(:assessment)

        get :index 

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq("Found Assessments")
      end

      it 'if there is no assessment is present' do
        get :index

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Assessments Found')
      end
    end

    context 'when user is not admin' do

      before do
        request.headers['token'] = token_student
      end
      
      it 'returns unauthorized status' do
        get :index 
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'POST #create' do 
    let(:assessment_params) { { assessment: attributes_for(:assessment) } }

    context 'when user is teacher' do 

      before do
        request.headers['token'] = token_teacher
      end

      it 'creates a new assessment' do
        post :create, params: assessment_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Assessment is created successfully')
      end

      it 'returns unprocessable entity when assessment creation fails' do
        assessments_params = { name:"" }
        post :create, params: { assessment: assessments_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
      end
    end

    context 'when user not teacher' do
      before do
        request.headers['token'] = token_admin
      end

      it 'returns unauthorized status' do
        post :create , params: { assessment: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end 


  describe 'PUT #update' do

    let(:assessment) { FactoryBot.create(:assessment) }
    context 'when user is an teacher' do
  
      before do
        request.headers['token'] = token_teacher
      end

      it 'updates the specified assessment' do
        assessment_params = { name: 'Java Test' }
        patch :update, params: { id: assessment.id, assessment: assessment_params }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Assessment Updated Successfully')
      end

      it 'returns unprocessable entity when question update fails' do
        assessment_params = { name: '' }
        put :update, params: { id: assessment.id, assessment: assessment_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'when user is not an teacher' do
  
      before do
        request.headers['token'] = token_admin
      end

      it 'returns unauthorized status' do
        put :update, params: { id: assessment.id, assessment: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end
  
  describe "GET #show_question" do
    context 'when the user is student' do

      before do
        request.headers['token'] = token_student
      end

      it 'it returns the assessment question when found' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        question2 = FactoryBot.create(:assessment_question, assessment: assessment)
        get :show_questions, params: { id: assessment.id }
        
        expect(response).to have_http_status(200)
      end

      it 'returns "No Questions Found" when no questions are found' do
        assessment = FactoryBot.create(:assessment)
        get :show_questions, params: { id: assessment.id }
  
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('No Questions Found for the Assessment')
      end
    end
    
    context 'when the user is not student' do

      before do
        request.headers['token'] = token_admin
      end

      it 'returns "You are not authorized" when user is not a student' do

        assessment = FactoryBot.create(:assessment)
  
        get :show_questions, params: { id: assessment.id }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  # describe ' POST #submit_answer' do
  #   context 'when the user is student' do
      
  #     let(:student_user) { FactoryBot.create(:user, role: 'student') }
  #     let(:token) { JWT.encode({ sub: student_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

  #     before do
  #       request.headers['token'] = token
  #     end

  #     it 'it submits the answer' do
  #       assessment = FactoryBot.create(:assessment)
  #       assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)

  #       post :submit_answer, params: { assessment_id: assessment.id, answer: "option1"}

  #       expect(response).to have_http_status(200)
  #     end
      
  #     it "returns an error for invalid submission" do
  #       assessment = FactoryBot.create(:assessment)
  #       assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)
  #       post "/assessments/#{assessment.id}/assessment_questions/#{assessment_question.id}/submit_answer", params: { assessment_id: assessment.id, assessment_question_id: 123, answer: nil }
  #       expect(response).to have_http_status(422)

  #       json_response = JSON.parse(response.body)
  #       expect(json_response["message"]).to eq("Invalid Submission")
  #       expect(json_response["errors"]).to eq("Question not found or answer not provided")
  #     end
  #   end

  #   context "when user is not a student" do
  #     before do
  #       sign_in teacher_user
  #     end

  #     it "returns an unauthorized error" do
  #       assessment = FactoryBot.create(:assessment)
  #       assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)
  #       post "/assessments/#{assessment.id}/assessment_questions/#{assessment_question.id}/submit_answer", params: { assessment_id: assessment.id, assessment_question_id: assessment_question.id, answer: "option1"}
  #       expect(response).to have_http_status(401)

  #       json_response = JSON.parse(response.body)
  #       expect(json_response["message"]).to eq("You are not authorized to perform this action")
  #     end
  #   end
  # end

  describe "POST #submit_answer" do
    context 'when the user is student' do
  
      before do
        request.headers['token'] = token_student
      end

      it 'calculates total marks and question results when correct_option is found' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        correct_option1 = FactoryBot.create(:option, assessment_question: question1, choice: 'correct_answer1')
        question1.update(correct_option: correct_option1.id)
      
        submitted_answers = { question1.id.to_s => 'correct_answer1'}
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
      
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['total_marks']).to eq(1)
        expect(response_body['results'][0]['is_correct']).to be(true)
      end

      it 'returns "Assessment not found" when assessment is not found' do
        submitted_answers = { "question_id_1" => "answer_1", "question_id_2" => "answer_2" }
        
        post :submit_answer, params: { id: 1, answers: submitted_answers }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Assessment not found')
      end
  
      it 'returns "Question not found" when assessment is not found' do
        assessment = FactoryBot.create(:assessment)
        submitted_answers = { "question_id_1" => "answer_1", "question_id_2" => "answer_2" }
        
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Question not found with ID: question_id_1')
      end
  
      it 'returns "Invalid Submission" when answers are not provided or in incorrect format' do
        assessment = FactoryBot.create(:assessment)
        submitted_answers = {}
        
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
    
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Invalid Submission')
      end
  
      it 'returns "Question not found" when a question ID is not found' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        submitted_answers = { '1' => 'submitted_answer1', '999' => 'submitted_answer2' }
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
  
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Correct option not found for Question with ID: 1')
      end 
    end
  
    context 'when the user is not a student' do

      before do
        request.headers['token'] = token_admin
      end

      it 'returns "You are not authorized" when user is not a student' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        submitted_answers = { '1' => 'submitted_answer1', '999' => 'submitted_answer2' }
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end

    context 'when the user is not a student' do
      let(:token) { JWT.encode({ sub: 111, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns "You are not authorized" when user is not a student' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        submitted_answers = { '1' => 'submitted_answer1', '999' => 'submitted_answer2' }
        post :submit_answer, params: { id: assessment.id, answers: submitted_answers }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('User not found')
      end
    end
  end
end
