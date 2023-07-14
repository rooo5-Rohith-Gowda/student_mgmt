class Academic < ApplicationRecord
    belongs_to :interest
    belongs_to :qualification
    belongs_to :user
    has_one_attached :governament_id
    has_one_attached :cv
  
    validates :college_name, :interest_id, :qualification_id, :career_goals, :language, :other_language, :specialization, :experiance, presence: true

    validates_uniqueness_of :user_id

    enum level: { level1: "level1", level2: "level2"}

end
  