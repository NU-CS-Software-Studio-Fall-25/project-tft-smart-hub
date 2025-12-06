require 'rails_helper'

RSpec.describe TeamComp, type: :model do
  describe 'validations' do
    subject { build(:team_comp) }
    
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:champions) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_length_of(:description).is_at_most(200) }
    it { is_expected.to validate_length_of(:notes).is_at_most(100) }

    it 'sets default set_identifier to TFT15' do
      team = build(:team_comp, set_identifier: nil)
      team.validate
      expect(team.set_identifier).to eq('TFT15')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:system_team) { create(:team_comp, team_type: 'system') }
    let(:user_team) { create(:team_comp, team_type: 'user', user:) }

    describe '.system_teams' do
      it 'returns only system teams' do
        expect(TeamComp.system_teams).to include(system_team)
        expect(TeamComp.system_teams).not_to include(user_team)
      end
    end

    describe '.user_teams' do
      it 'returns only user teams' do
        expect(TeamComp.user_teams).to include(user_team)
        expect(TeamComp.user_teams).not_to include(system_team)
      end
    end

    describe '.for_set' do
      let(:tft15_team) { create(:team_comp, set_identifier: 'TFT15') }
      let(:tft14_team) { create(:team_comp, set_identifier: 'TFT14') }

      it 'filters teams by set identifier' do
        expect(TeamComp.for_set('TFT15')).to include(tft15_team)
        expect(TeamComp.for_set('TFT15')).not_to include(tft14_team)
      end

      it 'returns all teams when set is blank' do
        expect(TeamComp.for_set(nil)).to include(tft15_team, tft14_team)
      end
    end
  end

  describe '#champion_names' do
    it 'parses comma-separated champion names' do
      team = create(:team_comp, champions: 'Aatrox, Braum, Caitlyn')
      names = team.champion_names
      expect(names).to eq(['Aatrox', 'Braum', 'Caitlyn'])
    end

    it 'strips whitespace from champion names' do
      team = create(:team_comp, champions: ' Aatrox ,  Braum  , Caitlyn ')
      names = team.champion_names
      expect(names).to eq(['Aatrox', 'Braum', 'Caitlyn'])
    end

    it 'rejects blank names' do
      team = create(:team_comp, champions: ' Aatrox ,  ,  Caitlyn ')
      names = team.champion_names
      expect(names).to eq(['Aatrox', 'Caitlyn'])
    end
  end

  describe '#champion_records' do
    it 'returns champion records from database' do
      aatrox = create(:champion, name: 'Aatrox', api_id: 'TFT15_Aatrox')
      braum = create(:champion, name: 'Braum', api_id: 'TFT15_Braum')
      team = create(:team_comp, champions: 'Aatrox, Braum')
      
      records = team.champion_records
      expect(records).to include(aatrox, braum)
    end

    it 'returns empty array when no matching champions' do
      team = create(:team_comp, champions: 'Nonexistent1, Nonexistent2')
      expect(team.champion_records).to be_empty
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets default set identifier to TFT15' do
        team = build(:team_comp, set_identifier: nil)
        team.validate
        expect(team.set_identifier).to eq('TFT15')
      end
    end
  end
end
