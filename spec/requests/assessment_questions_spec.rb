RSpec.describe AssessmentQuestionsController, type: :controller do

  let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
  let(:teacher_user) { FactoryBot.create(:user, role: 'teacher') }
  let(:token_admin) { JWT.encode({ sub: admin_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }
  let(:token_teacher) { JWT.encode({ sub: teacher_user.id, exp: 1.day.from_now.to_i }, 'your_secret_key') }

  describe "GET /index" do
    context 'admin user' do 
      before do
        request.headers['token'] = token_admin
      end
  
      it 'returns all the Assessment Question details present if present' do
        assessment_question1 = FactoryBot.create(:assessment_question)
        assessment_question2 = FactoryBot.create(:assessment_question)

        get :index
  
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Found Questions')
        expect(JSON.parse(response.body)['assessment_questions'].count).to eq(2)
      end
  
      it 'if there is no Assessment question' do
        get :index
  
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('No Questions Found')
        expect(JSON.parse(response.body)['assessment_questions']).to be_empty
      end
    end

    context 'when user is not admin' do

      before do
        request.headers['token'] = token_teacher
      end

      it 'returns unauthorized status' do
        get :index
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
        expect(JSON.parse(response.body)['assessment_questions']).to be_nil
      end
    end
  end

  describe "POST #create" do
    context "when user is admin" do

      before do
        request.headers['token'] = token_admin
      end

      context "with valid parameters" do
        let(:assessment) { FactoryBot.create(:assessment) }
        it "creates a new assessment question" do
          assessment_params = FactoryBot.attributes_for(:assessment_question, assessment_id: assessment.id)

          expect {
            post :create, params: { assessment_question: assessment_params }
          }.to change(AssessmentQuestion, :count).by(1)

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['message']).to eq('Question created successfully')
        end
      end

      context "with invalid parameters" do
        it "returns an unprocessable entity status" do
          invalid_params = { question: "", correct_option: "", level: "", assessment_id: nil }

          post :create, params: { assessment_question: invalid_params }

          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['message']).to eq('Unprosseable Entity')
        end
      end
    end

    context "if user is not admin" do

      before do
        request.headers['token'] = token_teacher
      end

      it "returns unauthorized status" do
        assessment_params = FactoryBot.attributes_for(:assessment_question)

        post :create, params: { assessment_question: assessment_params }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe "GET /show" do
    context 'if user is admin' do
      before do
        request.headers['token'] = token_admin
      end
  
      it 'returns the Assessment Question details present if present' do
        assessment_question = FactoryBot.create(:assessment_question)

        get :show, params: { id: assessment_question.id }
        
        expect(response).to have_http_status(200)
      end
  
      it 'if there is no Assessment question' do

        get :show, params: { id: 1 }
  
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to eq('Question Not Found')
      end
    end

    context 'non admin user' do
      before do
        request.headers['token'] = token_teacher
      end

      it 'returns unauthorized status' do

        assessment_question = FactoryBot.create(:assessment_question)
        
        get :show, params: { id: assessment_question.id }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
        expect(JSON.parse(response.body)['assessment_questions']).to be_nil
      end
    end
  end
  describe "PATCH /update" do
    context 'admin can perform this action' do 
      before do
        request.headers['token'] = token_admin
      end
  
      it 'updates the Assessment Question if valid parameters are provided' do
        assessment_question = FactoryBot.create(:assessment_question)
        updated_attributes = { question: 'Updated Question', correct_option: 'Option A' }
  
        patch :update, params: { id: assessment_question.id, assessment_question: updated_attributes }
  
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Question Updated Successfully')
  
        assessment_question.reload
  
        expect(assessment_question.question).to eq('Updated Question')
        expect(assessment_question.correct_option).to eq('Option A')
      end
  
      it 'returns unprocessable entity status if invalid parameters are provided' do
        assessment_question = FactoryBot.create(:assessment_question)
        invalid_attributes = { question: '', correct_option: '' }
  
        patch :update, params: { id: assessment_question.id, assessment_question: invalid_attributes }
  
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end
  
    context 'wnot admin' do
  
      before do
        request.headers['token'] = token_teacher
      end
  
      it 'returns unauthorized status' do
        assessment_question = FactoryBot.create(:assessment_question)
        updated_attributes = { question: 'Updated Question', correct_option: 'Option A' }
  
        patch :update, params: { id: assessment_question.id, assessment_question: updated_attributes }
  
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'user admin' do

      before do
        request.headers['token'] = token_admin
      end

      it 'deletes the assessment question' do
        assessment_question = FactoryBot.create(:assessment_question)

        expect {
          delete :destroy, params: { id: assessment_question.id }
        }.to change(AssessmentQuestion, :count).by(-1)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Question Deleted Successfully')
      end

      it 'deletes associated options when the assessment question is deleted' do
        assessment_question = FactoryBot.create(:assessment_question)
        FactoryBot.create_list(:option, 3, assessment_question: assessment_question)

        options_count_before_deletion = assessment_question.options.count

        expect {
          delete :destroy, params: { id: assessment_question.id }
        }.to change(Option, :count).by(-options_count_before_deletion)
      end

      it 'returns an error' do
        assessment_question = FactoryBot.create(:assessment_question)

        patch :update, params: { id: assessment_question.id, assessment_question: { question: '' } }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['message']).to eq('Unproccessable entity')
      end
    end

    context 'if user is role is not admin' do

      before do
        request.headers['token'] = token_teacher
      end

      it 'returns unauthorized status' do
        assessment_question = FactoryBot.create(:assessment_question)

        delete :destroy, params: { id: assessment_question.id }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq('You are not authorized to perform this action')
      end
    end
  end
end
