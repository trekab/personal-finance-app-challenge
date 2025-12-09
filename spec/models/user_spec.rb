require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:user) } # ensures uniqueness validation works

    it { should validate_presence_of(:email_address) }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should have_secure_password }
  end

  describe "secure password" do
    it "requires a password to create a users" do
      user = User.new(
        email_address: "test@example.com",
        name: "Test User",
        password: nil
      )
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "authenticates with correct password" do
      user = User.create!(
        email_address: "test@example.com",
        name: "Test User",
        password: "Password123"
      )
      expect(user.authenticate("Password123")).to eq(user)
    end

    it "fails authentication with incorrect password" do
      user = User.create!(
        email_address: "test@example.com",
        name: "Test User",
        password: "Password123"
      )
      expect(user.authenticate("WrongPassword")).to eq(false)
    end
  end

  describe "normalizations" do
    it "downcases and strips email addresses" do
      user = User.create!(
        email_address: "  UPPER@Example.COM  ",
        name: "Test User",
        password: "Password123"
      )
      expect(user.email_address).to eq("upper@example.com")
    end
  end

  describe "database constraints" do
    it "enforces unique email at the database level" do
      User.create!(
        email_address: "test@example.com",
        name: "User One",
        password: "Password123"
      )

      expect {
        User.insert_all!([
                           {
                             email_address: "test@example.com",
                             name: "User Two",
                             password_digest: User.new(password: "Password123").password_digest,
                             created_at: Time.current,
                             updated_at: Time.current
                           }
                         ])
      }.to raise_error(ActiveRecord::RecordNotUnique)

    end
  end
end

