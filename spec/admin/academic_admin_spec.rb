require 'rails_helper'

RSpec.describe Academic, type: :feature do
  let(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:interest) { FactoryBot.create(:interest, name: "Computer  Science") }
  let!(:qualification) { FactoryBot.create(:qualification, name: "Bachelor's Degree") }
  let!(:user) { FactoryBot.create(:user) }

  before do
    login_as(admin_user, scope: :admin_user)
  end

  CN = "Computer  Science"

  describe "Academic Index Page" do
    it "displays academic details correctly" do
      academic = FactoryBot.create(:academic, college_name: "ABC College", interest: interest, qualification: qualification, user: user)

      visit admin_academics_path

      expect(page).to have_content("ABC College")
      expect(page).to have_content(CN)
      expect(page).to have_content("Bachelor's Degree")
      expect(page).to have_content(user.email)
    end
  end

  describe "Academic New Page" do
    it "creates a new academic record" do
      visit new_admin_academic_path

      fill_in "College name", with: "XYZ University"
      select CN, from: "Interest"
      select("Computer Science and Engineering", from: "academic_qualification_id")

      fill_in "Language", with: "Become a Software Engineer"
      fill_in "Other language", with: "Become a Software Engineer"
      check "Currently working"  
      check "Availability"
      fill_in "Specialization", with: "Become a Software Engineer"
      fill_in "Experiance", with: "Become a Software Engineer"
      user = User.find_by(first_name: "Akashy")
      find("option", text: user.first_name).select_option if user

      click_button "Create Academic"

      expect(page).to have_content("Academic was successfully created.")
    end
  end

#   describe "Academic Edit Page" do
#     it "updates an existing academic record" do
#       academic = FactoryBot.create(:academic, college_name: "Old College Name", interest: interest, qualification: qualification, user: user)

#       visit edit_admin_academic_path(academic)

#       fill_in "College Name", with: "New College Name"
#       # Update other form fields as needed

#       click_button "Update Academic"

#       expect(page).to have_content("Academic was successfully updated.")
#       expect(page).to have_content("New College Name")
#     end
#   end

  describe "Academic Show Page" do
    it "displays the details of an academic record" do
      academic = FactoryBot.create(:academic, college_name: "XYZ University", interest: interest, qualification: qualification, user: user)

      visit admin_academic_path(academic)

      expect(page).to have_content("XYZ University")
      expect(page).to have_content(CN)
      expect(page).to have_content("Bachelor's Degree")
      expect(page).to have_content(user.email)
    end
  end
end
