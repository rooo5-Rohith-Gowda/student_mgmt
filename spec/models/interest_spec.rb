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

  describe '#to_csv' do
    let(:interest) { FactoryBot.create(:interest, name: 'JohnDoe') }

    it 'returns CSV data with correct headers and values' do
      csv_data = interest.to_csv

      csv_hash = CSV.parse(csv_data, headers: true).map(&:to_h).first

      expect(csv_hash.keys).to contain_exactly(*Interest.attribute_names.map(&:to_s))

      expect(csv_hash['id'].to_i).to eq(interest.id)
      expect(csv_hash['name']).to eq('JohnDoe')
    end
  end
end
