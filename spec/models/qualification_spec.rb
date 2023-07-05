require 'rails_helper'

RSpec.describe Qualification, type: :model do
  let(:qualification) { FactoryBot.create(:qualification) }
  describe 'Checks the valid Qualification' do
    it 'checks the presence of valid name' do
      qualification = build(:qualification)
      expect(qualification).to be_valid
    end

    it 'checks the presence of name' do
      qualification = build(:qualification, name: nil)
      expect(qualification).not_to be_valid
      expect(qualification.errors[:name]).to include("can't be blank")
    end
  end
end
