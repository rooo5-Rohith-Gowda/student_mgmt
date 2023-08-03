RSpec.describe AcademicsController, type: :controller do
  describe 'GET #index' do
    context 'when an admin user is authenticated' do
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns a list of academics' do
        academic1 = FactoryBot.create(:academic)
        academic2 = FactoryBot.create(:academic)
        academic3 = FactoryBot.create(:academic)

        get :index

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Found Academics')
        expect(json_response['academics'].count).to eq(3)
      end

      it 'returns a 404 status code when there are no academics' do
        get :index

        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('No Academics Found')
        expect(json_response['academics']).to be_empty
      end
    end

    context 'when a non-admin user is authenticated' do
      let(:student_user) { FactoryBot.create(:user, role: 'student') }
      let(:token) { JWT.encode({ sub: student_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns a 400 status code with an error message' do
        get :index

        expect(response).to have_http_status(401)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('your are not authorized to perform this action')
      end
    end

    context 'when no user is authenticated' do
      it 'returns a 401 status code with an error message' do
        get :index

        expect(response).to have_http_status(401)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Invalid token format')
      end
    end
  end

  describe 'POST #create' do
    context 'when a non-admin user is authenticated' do
      let(:student_user) { FactoryBot.create(:user, role: 'student') }
      let(:token) { JWT.encode({ sub: student_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      context 'when valid parameters are provided' do
        let(:interest) { FactoryBot.create(:interest) }
        let(:qualification) { FactoryBot.create(:qualification) }
        let(:academic_params) { attributes_for(:academic, user_id: student_user.id, interest_id: interest.id, qualification_id: qualification.id) }

        it 'creates a new academic' do
          post :create, params: { academic: academic_params }

          expect(response).to have_http_status(200)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Academics Created Successfully')
          expect(json_response['academic']).not_to be_nil
        end
      end

      context 'when invalid parameters are provided' do
        let(:invalid_params) { { college_name: '' } }

        it 'returns an error' do
          post :create, params: { academic: invalid_params }

          expect(response).to have_http_status(422)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Unprocessable Entity')
        end
      end
    end

    context 'when an admin user is authenticated' do
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

      before do
        request.headers['token'] = token
      end

      it 'returns a 401 status code with an error message' do
        post :create

        expect(response).to have_http_status(401)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('You no need academics to log in')
      end
    end

    context 'when no user is authenticated' do
      it 'returns a 401 status code with an error message' do
        post :create

        expect(response).to have_http_status(401)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Invalid token format')
      end
    end
  end

  describe '#check_user' do
    context 'when invalid token or user not found' do

      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.ago.to_i }, 'your_secret_key') }

        before do
          request.headers['token'] = token
        end
      it 'returns JSON with the error message and status :not_found' do
        get :index
        
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq('Invalid token or user not found')
      end
    end
  end
end
