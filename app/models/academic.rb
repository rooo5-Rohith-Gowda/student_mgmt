class Academic < ApplicationRecord
    belongs_to :interest
    belongs_to :qualification
    belongs_to :user
    has_one_attached :governament_id
    has_one_attached :cv
  
    validates :college_name, :interest_id, :qualification_id, :career_goals, :language, :other_language, :specialization, :experiance, :user_id, presence: true
end
  