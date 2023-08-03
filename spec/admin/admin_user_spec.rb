require 'rails_helper'

RSpec.describe AdminUser, type: :feature do
  describe 'AdminUser Index Page' do
    before do
      admin_user = FactoryBot.create(:admin_user, email: 'admin@example.com')

      login_as(admin_user, scope: :admin_user)
      visit admin_admin_users_path
    end

    it 'displays the email, current sign-in time, sign-in count, and creation time' do
      expect(page).to have_content('admin@example.com')
    end

    it 'displays the edit and delete actions' do
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete', exact_text: true)
    end
  end

  describe 'AdminUser New Page' do
    before do
      admin_user = FactoryBot.create(:admin_user, email: 'admin@example.com')

      login_as(admin_user, scope: :admin_user)

      visit new_admin_admin_user_path
    end

    it 'creates a new admin user' do
        visit new_admin_admin_user_path
      
        fill_in 'Email', with: 'newadmin@example.com'
        fill_in 'admin_user_password', with: 'password'
        fill_in 'admin_user_password_confirmation', with: 'password'
      
        click_button 'Create Admin user'
      
        expect(page).to have_content('Admin user was successfully created.')
    end
  end
end
