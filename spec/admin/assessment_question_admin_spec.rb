require 'rails_helper'

RSpec.describe Admin::AssessmentQuestionsController , type: :feature do
  let(:admin_user) { create(:admin_user) }
  let!(:assessment) { create(:assessment, name: 'Sample Assessment') }

  before do
    login_as(admin_user, scope: :admin_user)
  end

  describe 'Index Page' do
    let!(:assessment_question1) { create(:assessment_question, question: 'Question 1', assessment: assessment) }
    let!(:assessment_question2) { create(:assessment_question, question: 'Question 2', assessment: assessment) }

    it 'displays assessment question details correctly' do
      visit admin_assessment_questions_path

      expect(page).to have_content('Question 1')
      expect(page).to have_content('Question 2')
      expect(page).to have_content('Sample Assessment')
      expect(page).to have_content(assessment_question1.correct_option_choice)
      expect(page).to have_content(assessment_question2.correct_option_choice)
      expect(page).to have_link('Edit')
      expect(page).to have_link('Delete')
    end
  end

  describe 'New Page' do
    it 'creates a new assessment question' do
      visit new_admin_assessment_question_path

      fill_in 'Question', with: 'What is the capital of France?'
      select 'Sample Assessment', from: 'Assessment'
      fill_in 'Level', with: 'level1'
      click_button 'Create Assessment question'

      expect(page).to have_content('Assessment question was successfully created.')
    end
  end
end
