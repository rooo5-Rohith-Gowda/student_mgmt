require 'rails_helper'

RSpec.describe AssessmentQuestion, type: :model do
  
  let(:assessment_question) { FactoryBot.create(:assessment_question)}
  describe 'Validation' do
    it 'Valid Assessment Question' do 
      assessment_question = build(:assessment_question)
      expect(assessment_question).to be_valid
    end

    it 'Validates the presence of question in Assessment Question' do 
      assessment_question = build(:assessment_question, question: nil)
      expect(assessment_question).not_to be_valid
      expect(assessment_question.errors[:question]).to include("can't be blank")
    end

    it 'Validates the presence of correct_option in Assessment Question' do 
      assessment_question = build(:assessment_question, correct_option: nil)
      expect(assessment_question).not_to be_valid
      expect(assessment_question.errors[:correct_option]).to include("can't be blank")
    end

    it 'Validates the presence of level in Assessment Question' do 
      assessment_question = build(:assessment_question, level: nil)
      expect(assessment_question).not_to be_valid
      expect(assessment_question.errors[:level]).to include("can't be blank")
    end
  end

end 
