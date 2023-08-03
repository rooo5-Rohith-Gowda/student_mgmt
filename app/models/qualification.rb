class Qualification < ApplicationRecord
    has_one :academic
    has_one_attached :csv_file

    validates :name, presence: true
end
