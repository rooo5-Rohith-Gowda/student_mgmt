require 'rails_helper'

RSpec.describe Assessment, type: :model do
  
  let(:assessment) { FactoryBot.create(:assessment) }
  describe 'Validation' do
    it 'Valid Assessment' do
      assessment = build(:assessment)
      expect(assessment).to be_valid
    end

    it 'Invalid Assessment' do
      assessment = build(:assessment, name: "")
      expect(assessment).not_to be_valid
      expect(assessment.errors[:name]).to include("can't be blank")
    end
  end

end
