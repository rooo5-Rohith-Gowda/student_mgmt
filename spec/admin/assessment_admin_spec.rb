require 'rails_helper'

RSpec.describe Admin::AssessmentsController, type: :feature do
  let(:admin_user) { create(:admin_user) }

  before do
    login_as(admin_user, scope: :admin_user)
  end

  describe 'Index Page' do
    let!(:assessment1) { create(:assessment, name: 'Assessment 1') }
    let!(:assessment2) { create(:assessment, name: 'Assessment 2') }

    it 'displays assessment details correctly' do
      visit admin_assessments_path

      expect(page).to have_content('Assessment 1')
      expect(page).to have_content('Assessment 2')
      expect(page).to have_link('Edit') 
      expect(page).to have_link('Delete') 
    end
  end
end
