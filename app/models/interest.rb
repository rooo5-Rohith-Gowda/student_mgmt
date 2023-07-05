class Interest < ApplicationRecord
    has_one :academic
    
    validates :name, presence: true
end
