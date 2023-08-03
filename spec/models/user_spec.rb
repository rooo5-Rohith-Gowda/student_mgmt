require 'rails_helper'
require 'csv'

RSpec.describe User, type: :model do
  
  MSG = "can't be blank"

  describe 'Validation' do 
    it 'Valid User' do
      user = create(:user)
      expect(user).to be_valid
    end

    it 'validates the presence of email' do
      user  = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(MSG)
    end

    it 'validates the presence of password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(MSG)
    end

    it 'validates the presence of first_name' do
      user = build(:user, first_name: '')
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include(MSG)
    end

    it 'validates the presence of last_name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include(MSG)
    end

    it 'validates the presence of full_phone_number' do
      user = build(:user, full_phone_number: nil)
      expect(user).not_to be_valid
      expect(user.errors[:full_phone_number]).to include(MSG)
    end

    it 'validates the presence of gender' do
      user = build(:user, gender: nil)
      expect(user).not_to be_valid
      expect(user.errors[:gender]).to include(MSG)
    end

    it 'validates the presence of role' do
      user = build(:user, role: nil)
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include(MSG)
    end

    it 'validates the presence of date_of_birth' do
      user = build(:user, date_of_birth: nil)
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include(MSG)
    end

    it 'validates the presence of country' do
      user = build(:user, country: nil)
      expect(user).not_to be_valid
      expect(user.errors[:country]).to include(MSG)
    end

    it 'validates the presence of city' do
      user = build(:user, city: nil)
      expect(user).not_to be_valid
      expect(user.errors[:city]).to include(MSG)
    end

    it 'validates the presence of state' do
      user = build(:user, state: nil)
      expect(user).not_to be_valid
      expect(user.errors[:state]).to include(MSG)
    end

    it 'validates the presence of address' do
      user = build(:user, address: nil)
      expect(user).not_to be_valid
      expect(user.errors[:address]).to include(MSG)
    end

  end

  describe "#jwt_payload" do
    let(:user) { create(:user) }

    it 'returns a valid jwt_payload' do
      payload = user.jwt_payload

      expect(payload).to be_a(Hash)
      expect(payload).to include("jti" => user.jti)
    end
  end

  describe '#generate_jwt' do
    let(:user) { create(:user) }
    let(:jwt_payload) { { "jti" => user.jti } }
    let(:secret_key_base) { Rails.application.credentials.secret_key_base }

    it 'generates a JWT token' do
      expect(JWT).to receive(:encode).with(jwt_payload, secret_key_base)
      user.generate_jwt
    end
  end

  describe '#to_csv' do
    let(:user) { FactoryBot.create(:user, last_name: 'John Doe', email: 'john@example.com') }

    it 'returns CSV data with correct headers and values' do
      csv_data = user.to_csv

      csv_hash = CSV.parse(csv_data, headers: true).map(&:to_h).first

      expect(csv_hash.keys).to contain_exactly(*User.attribute_names.map(&:to_s))

      expect(csv_hash['id'].to_i).to eq(user.id)
      expect(csv_hash['last_name']).to eq('John Doe')
      expect(csv_hash['email']).to eq('john@example.com')
    end
  end

end
