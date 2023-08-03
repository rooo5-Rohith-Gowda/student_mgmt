require 'rails_helper'

RSpec.describe QualificationsController, type: :controller do
  describe 'GET #index' do
    context 'when the user is admin' do
      let(:admin_user) { FactoryBot.create(:user, role: "admin") }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns all the qualification present if present' do
        qualification1 = FactoryBot.create(:qualification)
        qualification = FactoryBot.create(:qualification)

        get :index

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Found Qualification')
        expect(JSON.parse(response.body)['qualifications'].count).to eq(2)
      end

      it 'returns 404 status if no qualification found' do
        get :index

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Qualification Found')
        expect(JSON.parse(response.body)['qualification']).to be_nil
      end
    end

    context 'when the user is not admin' do
      let(:non_admin_user) { FactoryBot.create(:user, role: "student") }
      let(:token) { JWT.encode({ sub: non_admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns 401 status with an error message' do
        get :index

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
        expect(JSON.parse(response.body)['qualification']).to be_nil
      end
    end
  end

  describe "POST #create" do
    context "when user is admin" do
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      context "with valid parameters" do
        let(:qualification) { FactoryBot.create(:qualification) }
        it "creates a new qualification" do
          qualification_params = FactoryBot.attributes_for(:qualification)

          expect {
            post :create, params: { qualification: qualification_params }
          }.to change(Qualification, :count).by(1)

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['message']).to eq('Qualification created successfully')
        end
      end

      context "with invalid parameters" do
        it "returns an unprocessable entity status" do
          invalid_params = { name: "" }

          post :create, params: { qualification: invalid_params }

          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
        end
      end
    end

    context "when user is not admin" do
      let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
      let(:token) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it "returns unauthorized status" do
        qualification_params = FactoryBot.attributes_for(:qualification)

        post :create, params: { qualification: qualification_params }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not autharized to perform this action')
      end
    end
  end
end
