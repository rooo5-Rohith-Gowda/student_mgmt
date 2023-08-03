RSpec.describe InterestsController, type: :controller do
  let(:admin_user) { FactoryBot.create(:user, role: "admin") }
  let(:token) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }
  let(:student_user) { FactoryBot.create(:user, role: "student") }
  let(:token_student) { JWT.encode({ sub: student_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

  shared_examples_for 'authorized user' do
    before do
      request.headers['token'] = token
    end

    it 'returns all the interests present if present' do
      interest1 = FactoryBot.create(:interest)
      interest2 = FactoryBot.create(:interest)

      get :index

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['message']).to eq('Found Interests')
      expect(JSON.parse(response.body)['interests'].count).to eq(2)
    end

    it 'returns 404 status if no interests found' do
      get :index

      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['message']).to eq('No Interests Found')
      expect(JSON.parse(response.body)['interests']).to be_empty
    end
  end

  describe 'GET #index' do
    context 'when the user is admin' do
      it_behaves_like 'authorized user'
    end

    context 'when the user is not admin' do
      before do
        request.headers['token'] = token_student
      end

      it 'returns 401 status with an error message' do
        get :index

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
        expect(JSON.parse(response.body)['interests']).to be_nil
      end
    end
  end

  describe "POST #create" do
    context "when user is admin" do
      before do
        request.headers['token'] = token
      end

      context "with valid parameters" do
        let(:interest_params) { FactoryBot.attributes_for(:interest) }

        it "creates a new interest question" do
          expect {
            post :create, params: { interest: interest_params }
          }.to change(Interest, :count).by(1)

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['message']).to eq('Interest created successfully')
        end

        it "returns an unprocessable entity status with invalid parameters" do
          invalid_params = { name: "" }

          post :create, params: { interest: invalid_params }

          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
        end
      end
    end

    context "when user is not admin" do
      before do
        request.headers['token'] = token_student
      end

      it "returns unauthorized status" do
        interest_params = FactoryBot.attributes_for(:interest)

        post :create, params: { interest: interest_params }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('Only admin can create the interest')
      end
    end
  end
end
