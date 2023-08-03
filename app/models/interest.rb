require 'csv'

class Interest < ApplicationRecord
    has_one :academic
    has_one_attached :csv_file
    
    validates :name, presence: true

    def to_csv
        CSV.generate(headers: true) do |csv|
          csv << Interest.attribute_names
          csv << attributes.values
        end
    end
end
