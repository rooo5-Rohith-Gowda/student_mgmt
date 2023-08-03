require 'rails_helper'

RSpec.describe OptionsController, type: :controller do  
  MSG = 'You are not authorized to perform this action'
  let(:assessment_question) { FactoryBot.create(:assessment_question)}

  describe "GET /index" do
    context 'when user is admin' do

      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns all the Options if present' do
        option = FactoryBot.create(:option)
        option1 = FactoryBot.create(:option)

        get :index 

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq("Found Options")
      end

      it 'if there is no options present' do
        get :index

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Options Found')
      end
    end

    context 'when user is not admin' do
      let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
      let(:token) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end
      
      it 'returns unauthorized status' do
        get :index 
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq(MSG)
      end
    end
  end

  describe 'POST #create' do 
    let(:option_params) { { option: attributes_for(:option, assessment_question_id: assessment_question.id) } }

    context 'when user is admin' do 
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'creates a new option' do
        post :create, params: option_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Options created successfully')
      end

      it 'returns unprocessable entity when option creation fails' do
        option_params = { choice:"" }
        post :create , params: { option: option_params, assessment_question_id: assessment_question.id}
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
      end
    end

    context 'when user not admin' do

      let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
      let(:token) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns 401 status' do
        post :create , params: { option: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq(MSG)
      end
    end
  end 


  describe 'PUT #update' do

    let(:option) { FactoryBot.create(:option) }
    context 'when user is an admin' do
      
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'updates the specified option' do
        option_params = { choice: 'option b' }
        patch :update, params: { id: option.id, option: option_params }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Option Updated Successfully')
      end

      it 'returns unprocessable entity when option update fails' do
        option_params = { choice: '' }
        patch :update, params: { id: option.id, option: option_params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'when user is not an admin' do

      let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
      let(:token) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'gives unauthorized status' do
        put :update, params: { id: option.id, option: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq(MSG)
      end
    end
  end
end
