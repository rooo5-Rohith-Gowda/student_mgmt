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
      expect(assessment_question).to be_valid
    end

    it 'Validates the presence of level in Assessment Question' do 
      assessment_question = build(:assessment_question, level: nil)
      expect(assessment_question).not_to be_valid
      expect(assessment_question.errors[:level]).to include("can't be blank")
    end
  end

  describe '#correct_option_choice' do
    let(:assessment) { FactoryBot.create(:assessment) }
    let(:question) { FactoryBot.create(:assessment_question, assessment: assessment) }
    let!(:correct_option) { FactoryBot.create(:option, assessment_question: question, choice: 'correct_answer1') }
    let!(:incorrect_option) { FactoryBot.create(:option, assessment_question: question, choice: 'wrong_answer2') }

    it 'returns the correct option choice' do
      question.update(correct_option: correct_option.id)
      expect(question.correct_option_choice).to eq('correct_answer1')
    end

    it 'returns nil if correct option is not set' do
      question.update(correct_option: nil)
      expect(question.correct_option_choice).to be_nil
    end

    it 'returns nil if correct option is not found' do
      question.update(correct_option: 9999) # Assuming no option has ID 9999
      expect(question.correct_option_choice).to be_nil
    end
  end

end 
