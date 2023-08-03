require 'rails_helper'

RSpec.describe "Admin Dashboard", type: :feature do
  before do
    admin_user = AdminUser.create(email: 'admin@example.com',password: "password", password_confirmation: "password")
  
    login_as(admin_user, scope: :admin_user)
  
    visit admin_admin_users_path
  end
  it "displays the welcome message and call to action" do
    visit admin_dashboard_path
  
    expect(page).to have_content(I18n.t("active_admin.dashboard_welcome.welcome"))
    expect(page).to have_content(I18n.t("active_admin.dashboard_welcome.call_to_action"))
  end
end