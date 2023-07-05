require 'rails_helper'

RSpec.describe "Assessments", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:teacher_user) { FactoryBot.create(:user, role: "teacher") }
  let(:student) { FactoryBot.create(:user, role: "student") }

  describe "GET /index" do
    context 'when user is admin' do

      before do
        sign_in admin_user
      end

      it 'returns all the assessment if present' do
        assessment = create(:assessment)
        assessment1 = create(:assessment)

        get '/assessments' 

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq("Found Assessments")
      end

      it 'if there is no assessment is present' do
        get '/assessments'

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Assessments Found')
      end
    end

    context 'when user is not admin' do
      before do
        sign_in(student)
      end
      
      it 'returns unauthorized status' do
        get '/assessments' 
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'POST #create' do 
    let(:assessment_params) { { assessment: attributes_for(:assessment) } }

    context 'when user is teacher' do 
      before do
        sign_in(teacher_user)
      end

      it 'creates a new assessment' do
        post '/assessments', params: assessment_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Assessment is created successfully')
      end

      it 'returns unprocessable entity when assessment creation fails' do
        assessments_params = { name:"" }
        post '/assessments' , params: { assessment: assessments_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
      end
    end

    context 'when user not teacher' do
      before { sign_in(student) }

      it 'returns unauthorized status' do
        post '/assessment_questions' , params: { assessment: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end 

  describe "GET #show" do    
    context 'when user is a teacher' do
      before { sign_in(teacher_user) }
      
      it 'returns the assessment when assessment is found' do
        assessment = FactoryBot.create(:assessment)
        assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)
        get "/assessments/#{assessment.id}"
        expect(response).to have_http_status(200)
      end

      it 'returns "No Questions Found" when no questions are found' do
        assessment = FactoryBot.create(:assessment)
        get "/assessments/#{assessment.id}"
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Questions Found')
      end

      it 'returns "Assessment Not Found" when assessment is not found' do
        non_existent_id = Assessment.maximum(:id).to_i + 1
        get "/assessments/#{non_existent_id}"
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('Assessment Not Found')
      end
    end

    context 'when user is not a teacher' do
      before do
        sign_in student
      end

      it 'returns "You are not authorized to perform this action" message' do
        assessment = FactoryBot.create(:assessment)
        get "/assessments/#{assessment.id}"
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'PUT #update' do

    let(:assessment) { FactoryBot.create(:assessment) }
    context 'when user is an teacher' do
      before { sign_in(teacher_user) }

      it 'updates the specified assessment' do
        assessment_params = { name: 'Java Test' }
        patch '/assessments/1', params: { id: assessment.id, assessment: assessment_params }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Assessment Updated Successfully')
      end

      it 'returns unprocessable entity when question update fails' do
        assessment_params = { name: '' }
        put '/assessments/1', params: { id: assessment.id, assessment: assessment_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'when user is not an teacher' do
      before { sign_in(admin_user) }

      it 'returns unauthorized status' do
        put '/assessments/1', params: { id: assessment.id, assessment: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end
  
  describe "GET #show_question" do
    context 'when the user is student' do
      before do
        sign_in student
      end

      it 'it returns the assessment question when found' do
        assessment = FactoryBot.create(:assessment)
        question1 = FactoryBot.create(:assessment_question, assessment: assessment)
        question2 = FactoryBot.create(:assessment_question, assessment: assessment)
        get '/assessments/1/show_questions'
        
        expect(response).to have_http_status(200)
      end

      it 'returns "No Questions Found" when no questions are found' do
        assessment = FactoryBot.create(:assessment)
        get "/assessments/#{assessment.id}/show_questions"
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Questions Found for the Assessment')
      end
    end
    
    context 'when the user is not student' do
      
      before {sign_in(teacher_user)}

      it 'returns "You are not authorized" when user is not a student' do
  
        get "/assessments/1/show_questions"
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe ' POST #submit_answer' do
    context 'when the user is student' do
      before do
        sign_in student
      end

      it 'it submits the answer' do
        assessment = FactoryBot.create(:assessment)
        assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)

        post "/assessments/#{assessment.id}/assessment_questions/#{assessment_question.id}/submit_answer", params: { assessment_id: assessment.id, assessment_question_id: assessment_question.id, answer: "option1"}

        expect(response).to have_http_status(200)
      end
      
      it "returns an error for invalid submission" do
        assessment = FactoryBot.create(:assessment)
        assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)
        post "/assessments/#{assessment.id}/assessment_questions/#{assessment_question.id}/submit_answer", params: { assessment_id: assessment.id, assessment_question_id: 123, answer: nil }
        expect(response).to have_http_status(422)

        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Invalid Submission")
        expect(json_response["errors"]).to eq("Question not found or answer not provided")
      end
    end

    context "when user is not a student" do
      before do
        sign_in teacher_user
      end

      it "returns an unauthorized error" do
        assessment = FactoryBot.create(:assessment)
        assessment_question = FactoryBot.create(:assessment_question, assessment: assessment)
        post "/assessments/#{assessment.id}/assessment_questions/#{assessment_question.id}/submit_answer", params: { assessment_id: assessment.id, assessment_question_id: assessment_question.id, answer: "option1"}
        expect(response).to have_http_status(401)

        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("You are not authorized to perform this action")
      end
    end
  end
end
