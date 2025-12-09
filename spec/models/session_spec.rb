require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      session = build(:session)
      expect(session).to be_valid
    end

    it 'is invalid without a users' do
      session = build(:session, user: nil)
      expect(session).not_to be_valid
    end
  end

  describe 'database columns' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:ip_address).of_type(:string) }
    it { should have_db_column(:user_agent).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'factory' do
    it 'creates a valid session' do
      session = create(:session)
      expect(session).to be_persisted
      expect(session.user).to be_present
    end

    it 'creates a session with custom attributes' do
      session = create(:session, ip_address: '192.168.1.1', user_agent: 'Custom Agent')
      expect(session.ip_address).to eq('192.168.1.1')
      expect(session.user_agent).to eq('Custom Agent')
    end
  end
end