require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:likes) }
    it { is_expected.to have_many(:favorites) }
  end

  describe '#authenticate' do
    let(:user) { create(:user, password: 'Test123!@#') }

    it 'returns user when password is correct' do
      result = user.authenticate('Test123!@#')
      expect(result).to eq(user)
    end

    it 'returns false when password is incorrect' do
      result = user.authenticate('wrongpassword')
      expect(result).to be_falsey
    end
  end

  describe '#admin?' do
    it 'returns true for admin user' do
      user = create(:user, role: 'admin')
      expect(user.admin?).to be true
    end

    it 'returns false for regular user' do
      user = create(:user, role: 'user')
      expect(user.admin?).to be false
    end
  end
end
