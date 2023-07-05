require 'rails_helper'

RSpec.describe Interest, type: :model do
  let(:interest) { FactoryBot.create(:interest)}
  
  describe 'validates the name' do
    it 'when the name is nil' do
      interest = build(:interest, name: '')

      expect(interest).not_to be_valid
      expect(interest.errors[:name]).to include("can't be blank")
    end

    it 'when the name is present' do 
      interest = build(:interest)

      expect(interest).to be_valid
    end
  end
end
