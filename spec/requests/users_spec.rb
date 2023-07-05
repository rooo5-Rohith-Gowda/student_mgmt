require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::IntegrationHelpers

  describe "GET #show" do
    let(:user) { create(:user) }
    let(:academic) { create(:academic) }

    it "when user has academic details it returns both user and academic details" do
      user.update(academic: academic)

      get :show, params: { id: user.id }

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["user"]["id"]).to eq(user.id)
      expect(JSON.parse(response.body)["data"]["academic"]["id"]).to eq(academic.id)
    end

    it "when user do not have academics it returns user data" do
      get :show, params: { id: user.id }

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["user"]["id"]).to eq(user.id)
      expect(JSON.parse(response.body)["message"]).to eq("Academic details not found for this user.")
    end
  end
end
