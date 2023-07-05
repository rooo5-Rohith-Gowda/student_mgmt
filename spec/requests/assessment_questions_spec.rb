require 'rails_helper'

RSpec.describe "AssessmentQuestions", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:teacher_user) { FactoryBot.create(:user, role: "teacher") }
  let(:assessment) { FactoryBot.create(:assessment) }
  # let(:assessment_question) { FactoryBot.create(:assessment_question) }

  describe "GET /index" do

    context 'when user is admin' do 
      before do
        sign_in admin_user
      end
  
      it 'returns all the Assessment Question details present if present' do
        assessment_question1 = create(:assessment_question)
        assessment_question2 = create(:assessment_question)
  
        get '/assessment_questions'
  
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Found Questions')
      end
  
      it 'if there is no Assessment question' do
        get '/assessment_questions'
  
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Questions Found')
      end
    end

    context 'when user is not admin' do
      before do
        sign_in teacher_user
      end

      it 'returns unauthorized status' do
        get '/assessment_questions'
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
    
  end


  describe 'POST #create' do
    let(:assessment_questions) { attributes_for(:assessment_question, assessment_id: assessment.id) }

    context 'when user is an admin' do
      before do
        sign_in(admin_user)
      end

      it 'creates a new assessment question' do
        post '/assessment_questions' , params: { assessment_question: assessment_questions }
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Question created successfully')
      end

      it 'returns unprocessable entity when question creation fails' do
        question_params = { question: '', correct_option: '', level: '', assessment_id: '' }
        post '/assessment_questions' , params: { assessment_question: question_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        post '/assessment_questions' , params: { assessment_question: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'GET #show' do
    let(:assessment_question) { FactoryBot.create(:assessment_question) }

    context 'when user is an admin' do
      
      before { sign_in(admin_user) }

      it 'returns the specified assessment question' do
        assessment_question_params = create(:assessment_question, assessment_id: assessment.id)
        get '/assessment_questions/1', params: { id: assessment_question_params.id }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['question']).to eq(assessment_question_params.question)
        expect(JSON.parse(response.body)['options']).to eq(assessment_question_params.options.pluck(:text))
      end

      it 'returns not found when the question is not found' do
        get '/assessment_questions/3', params: { id: 15 }
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('Question Not Found')
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        assessment_question_params = create(:assessment_question, assessment_id: assessment.id)
        get '/assessment_questions/1', params: { id: assessment_question.id }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'PUT #update' do

    let(:assessment_question) { FactoryBot.create(:assessment_question) }
    context 'when user is an admin' do
      before { sign_in(admin_user) }

      it 'updates the specified assessment question' do
        question_params = { question: 'Updated question' }
        put '/assessment_questions/1', params: { id: assessment_question.id, assessment_question: question_params }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Question Updated Successfully')
        expect(assessment_question.reload.question).to eq('Updated question')
      end

      it 'returns unprocessable entity when question update fails' do
        question_params = { question: '' }
        put '/assessment_questions/1', params: { id: assessment_question.id, assessment_question: question_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        put '/assessment_questions/1', params: { id: assessment_question.id, assessment_question: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:assessment_question) { FactoryBot.create(:assessment_question) }
    context 'when user is an admin' do
      before { sign_in(admin_user) }

      it 'deletes the specified assessment question' do
        delete '/assessment_questions/1', params: { id: assessment_question.id }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Question Deleted Successfully')
        expect(AssessmentQuestion.find_by(id: assessment_question.id)).to be_nil
      end

      it 'returns unauthorized when question deletion fails' do
        allow_any_instance_of(AssessmentQuestion).to receive(:delete).and_return(false)
        delete '/assessment_questions/1', params: { id: assessment_question.id }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('Unauthorized')
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        delete '/assessment_questions/1', params: { id: assessment_question.id }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end
end
