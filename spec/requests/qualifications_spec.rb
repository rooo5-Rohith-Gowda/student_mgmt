require 'rails_helper'

RSpec.describe "Qualification", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:teacher_user) { FactoryBot.create(:user, role: "teacher") }

  let(:qualification) { FactoryBot.create(:qualification) }
  describe "GET /index" do
    context 'when the user is admin' do
      before do
        sign_in admin_user
      end

      it 'returns all the qualifications present if present' do
        qualification1 = create(:qualification)
        qualification2 = create(:qualification)

        get '/qualifications'

        expect(response).to have_http_status(200)
      end

      it 'if there is no qualifications' do
        get '/qualifications'

        expect(response).to have_http_status(404)
      end
    end

    context 'when the user is not admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        get '/qualifications'
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe "POST /create" do
    let(:qualification_attributes) { attributes_for(:qualification) }

    context 'when user is an admin' do
      before do
        sign_in(admin_user)
      end

      it 'creating new qualification with valid params' do
        post '/qualifications', params: {
          qualification: qualification_attributes
        }
        expect(response).to have_http_status(200)
        expect(Qualification.count).to eq(1)
      end 

      it 'creating new qualification with invalid params' do
        post '/qualifications', params: {
          qualification: qualification_attributes.merge(name: '')
        }
        expect(response).to have_http_status(422)
        expect(Qualification.count).to eq(0)
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        post '/qualifications' , params: { qualification: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not autharized to perform this action')
      end
    end
  end
end
