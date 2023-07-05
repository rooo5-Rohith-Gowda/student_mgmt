require 'rails_helper'

RSpec.describe "Academics", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:interest) { FactoryBot.create(:interest) }
  let(:qualification) { FactoryBot.create(:qualification) }
  let(:user) { FactoryBot.create(:user) }
  describe "GET /index" do
    it 'returns all the academic details present if present' do
      academic1 = create(:academic)
      academic2 = create(:academic)

      get '/academics'

      expect(response).to have_http_status(200)
    end

    it 'if there is no academics' do
      get '/academics'

      expect(response).to have_http_status(404)
    end
  end

  describe 'POST #create' do
    let(:academic_params) { attributes_for(:academic, user_id: user.id, interest_id: interest.id, qualification_id: qualification.id) }

    context 'when valid parameters are provided' do
      it 'creates a new academic' do
        post '/academics', params: { academic: academic_params }

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Academics Created Successfully')
        expect(json_response['academic']).not_to be_nil
      end
    end

    context 'when invalid parameters are provided' do
      let(:invalid_params) { academic_params.except(:college_name) }

      it 'returns an error' do
        post '/academics', params: { academic: invalid_params }

        expect(response).to have_http_status(422)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Unprosseable Entity')
      end
    end
  end
end
