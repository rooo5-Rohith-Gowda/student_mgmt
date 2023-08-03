require 'devise/jwt'
require 'csv'

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  has_one :academic
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :first_name, :last_name, :email, :gender, :role, :date_of_birth, :country, :city, :state, :address, presence: true
  validates :password, presence: true, length: {minimum: 8}
  validates :full_phone_number, presence: true, format: { with: /\A\+\d{12}\z/, message: "Invalid format" } 

  enum role: { student: "student", admin: "admin", teacher: "teacher"}

  enum gender: { male: "male", female: "female", others: "others"}
  
  def jwt_payload
    super
  end

  def generate_jwt
    JWT.encode(jwt_payload, Rails.application.credentials.secret_key_base )
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << User.attribute_names
      csv << attributes.values
    end
  end
end
