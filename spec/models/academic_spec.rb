require 'rails_helper'

RSpec.describe Academic, type: :model do
    let(:user) {FactoryBot.create(:user)} 
    let(:interest) {FactoryBot.create(:interest)}
    let(:qualification) {FactoryBot.create(:qualification)}
    let(:academic) {FactoryBot.create(:academic)}

    describe 'Validation' do
        it 'valid academic record' do 
            academic = build(:academic, user_id: user.id, interest_id: interest.id, qualification_id: qualification.id)
            expect(academic).to be_valid
        end
        it 'validates presence of college_name' do
            academic = build(:academic, college_name: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of interest_id' do
            academic = build(:academic, interest_id: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of qualification_id' do
            academic = build(:academic, qualification_id: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of career_goals' do
            academic = build(:academic, career_goals: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of language' do
            academic = build(:academic, language: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of other_language' do
            academic = build(:academic, other_language: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of specialization' do
            academic = build(:academic, specialization: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of experiance' do
            academic = build(:academic, experiance: nil)
            expect(academic).not_to be_valid
        end
      
        it 'validates presence of user_id' do
            academic = build(:academic, user_id: nil)
            expect(academic).not_to be_valid
        end
    end

    describe 'associations' do
        it 'belongs to interest' do
          expect(Academic.reflect_on_association(:interest).macro).to eq(:belongs_to)
        end
    
        it 'belongs to qualification' do
          expect(Academic.reflect_on_association(:qualification).macro).to eq(:belongs_to)
        end
    
        it 'belongs to user' do
          expect(Academic.reflect_on_association(:user).macro).to eq(:belongs_to)
        end
    end
end
