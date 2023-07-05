require 'rails_helper'

RSpec.describe Option, type: :model do

  let(:option) { FactoryBot.create(:option) }
  describe 'Validation' do
    it 'Valid Option' do
      option = build(:option)
      expect(option).to be_valid
    end

    it 'Invalid Option' do
      option = build(:option, choice: "")
      expect(option).not_to be_valid
      expect(option.errors[:choice]).to include("can't be blank")
    end
  end
end
