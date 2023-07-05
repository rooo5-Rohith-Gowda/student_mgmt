require 'rails_helper'

RSpec.describe "Interests", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:teacher_user) { FactoryBot.create(:user, role: "teacher") }

  describe "GET #index" do

    context 'when the user is admin' do
      before do
        sign_in admin_user
      end
      
      it 'returns all the intrests present if present' do
        interest1 = create(:interest)
        interest2 = create(:interest)

        get '/interests'

        expect(response).to have_http_status(200)
      end

      it 'if there is no interest' do
        get '/interests'

        expect(response).to have_http_status(404)
      end
    end

    context 'when the user is not admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        get '/interests'
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe "POST /create" do
    let(:interest_attributes) { attributes_for(:interest) }
    context 'when user is an admin' do
      before do
        sign_in(admin_user)
      end
      it 'creating new interest with valid params' do
        post '/interests', params: {
          interest: interest_attributes
        }
        expect(response).to have_http_status(200)
        expect(Interest.count).to eq(1)
      end 

      it 'creating new interest wit invalid params' do
        post '/interests', params: {
          interest: interest_attributes.merge(name: '')
        }
        expect(response).to have_http_status(422)
        expect(Interest.count).to eq(0)
      end
    end

    context 'when user is not an admin' do
      before { sign_in(teacher_user) }

      it 'returns unauthorized status' do
        post '/interests' , params: { interest: {} }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('Only admin can create the interest')
      end
    end
  end
end
