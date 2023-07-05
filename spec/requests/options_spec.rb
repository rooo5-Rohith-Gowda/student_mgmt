require 'rails_helper'

RSpec.describe "Options", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:teacher_user) { FactoryBot.create(:user, role: "teacher") }
  let(:student) { FactoryBot.create(:user, role: "student") }
  let(:assessment_question) { FactoryBot.create(:assessment_question)}

  describe "GET /index" do
    context 'when user is admin' do

      before do
        sign_in admin_user
      end

      it 'returns all the Options if present' do
        option = create(:option)
        option1 = create(:option)

        get '/options' 

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq("Found Options")
      end

      it 'if there is no options present' do
        get '/options'

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Options Found')
      end
    end

    context 'when user is not admin' do
      before do
        sign_in(student)
      end
      
      it 'returns unauthorized status' do
        get '/options' 
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'POST #create' do 
    let(:option_params) { { option: attributes_for(:option, assessment_question_id: assessment_question.id) } }

    context 'when user is admin' do 
      before do
        sign_in(admin_user)
      end

      it 'creates a new option' do
        post '/options', params: option_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Options created successfully')
      end

      it 'returns unprocessable entity when assessment creation fails' do
        option_params = { choice:"" }
        post '/options' , params: { option: option_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
      end
    end

    context 'when user not admin' do
      before { sign_in(student) }

      it 'returns unauthorized status' do
        post '/options' , params: { option: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end 


  describe 'PUT #update' do

    let(:option) { FactoryBot.create(:option) }
    context 'when user is an admin' do
      before { sign_in(admin_user) }

      it 'updates the specified assessment' do
        option_params = { choice: 'option b' }
        patch '/options/1', params: { id: option.id, option: option_params }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Option Updated Successfully')
      end

      it 'returns unprocessable entity when question update fails' do
        option_params = { choice: '' }
        patch '/options/1', params: { id: option.id, option: option_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        put '/options/1', params: { id: option.id, option: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end
end
