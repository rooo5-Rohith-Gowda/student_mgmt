require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  include Devise::Test::IntegrationHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:user_attributes) { attributes_for(:user) }

    context 'when valid parameters are provided' do
      it 'creates a new user' do
        post :create, format: :json, params: {
          data: {
            type: 'sms_account',
            user: user_attributes
          }
        }
        expect(response).to have_http_status(200)
        p User.count
        expect(User.count).to eq(1)
      end
    end
    
    context 'when invalid paramerets are provided' do
      it 'returns an error' do
        post :create, params: {
          data: {
            type: "sms_account",
            user: user_attributes.merge(email: '')
          }
        }
        expect(response).to have_http_status(422)
        expect(User.count).to eq(0)
      end
    end
    
    context 'when account already exists without academic' do
      let!(:existing_user) { create(:user, email: user_attributes[:email]) }

      it 'updates the phone number and sends OTP' do
        post :create, params: {
          data: {
            type: "sms_account",
            user: user_attributes
          }
        }
        expect(response).to have_http_status(200)
        expect(existing_user.reload.full_phone_number).to eq(user_attributes[:full_phone_number])
      end
    end

    context 'when account already exist with academic' do
      let!(:existing_user) { create(:user, email: user_attributes[:email]) }

      it 'returns an error' do
        post :create, params: {
          data: {
            type: "sms_account",
            user: user_attributes
          }
        }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Account already exists, Verification code has been sent on your phone number, Please verify your phone number number to activate your account" )
      end
    end

    context 'when invalid account type is provided' do
      it 'returns error messgae' do 
        post :create, params: {
          data: {
            type: "invalid_type",
            user: user_attributes
          }
        }
        expect(response).to have_http_status(200)
      end
    end

  end 
end
