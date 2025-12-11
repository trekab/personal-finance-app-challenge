require "rails_helper"

RSpec.describe Pot, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:target) }
    it { should validate_numericality_of(:target).is_greater_than(0) }

    it { should validate_presence_of(:theme) }
    it { should validate_presence_of(:pot_name) }

    it "validates uniqueness of theme scoped to user" do
      create(:pot, user: user, theme: "Green")
      duplicate = build(:pot, user: user, theme: "Green")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:theme]).to include("is already used by another budget")
    end
  end

  describe "#total_saved" do
    it "currently returns 500 (placeholder)" do
      pot = build(:pot)
      expect(pot.total_saved).to eq(500)
    end
  end

  describe "#percentage_saved" do
    let(:pot) { build(:pot, target: 1000) }

    before do
      allow(pot).to receive(:total_saved).and_return(250)
    end

    it "calculates percentage saved" do
      expect(pot.percentage_saved).to eq(25.0)
    end

    it "returns 0 when target is zero" do
      pot.target = 0
      expect(pot.percentage_saved).to eq(0)
    end
  end

  describe "#target_reached?" do
    let(:pot) { build(:pot, target: 500) }

    it "returns true when total_saved >= target" do
      allow(pot).to receive(:total_saved).and_return(600)
      expect(pot.target_reached?).to be true
    end

    it "returns false when total_saved < target" do
      allow(pot).to receive(:total_saved).and_return(300)
      expect(pot.target_reached?).to be false
    end
  end

  describe "#remaining_amount" do
    let(:pot) { build(:pot, target: 1000) }

    it "returns target - total_saved when still saving" do
      allow(pot).to receive(:total_saved).and_return(200)
      expect(pot.remaining_amount).to eq(800)
    end

    it "returns 0 when total_saved >= target" do
      allow(pot).to receive(:total_saved).and_return(1200)
      expect(pot.remaining_amount).to eq(0)
    end
  end

  describe ".available_themes" do
    let!(:pot1) { create(:pot, user: user, theme: "Green") }
    let!(:pot2) { create(:pot, user: user, theme: "Yellow") }

    it "returns themes not used by the user" do
      expect(Pot.available_themes(nil, user.id)).to match_array(
                                                      Pot::THEMES - ["Green", "Yellow"]
                                                    )
    end

    it "excludes a pot when exclude_id is used" do
      expect(Pot.available_themes(pot1.id, user.id)).to match_array(
                                                          Pot::THEMES - ["Yellow"]
                                                        )
    end
  end

  describe ".used_themes" do
    let!(:pot1) { create(:pot, user: user, theme: "Green") }
    let!(:pot2) { create(:pot, user: user, theme: "Cyan") }

    it "returns all themes used by the user" do
      expect(Pot.used_themes(nil, user.id)).to match_array(["Green", "Cyan"])
    end

    it "excludes a pot when exclude_id is used" do
      expect(Pot.used_themes(pot2.id, user.id)).to match_array(["Green"])
    end
  end

  describe "#theme_used?" do
    let!(:pot1) { create(:pot, user: user, theme: "Green") }
    let!(:pot2) { create(:pot, user: user, theme: "Red") }

    it "returns true if theme is used by another pot of same user" do
      expect(pot1.theme_used?("Red", user.id)).to be true
    end

    it "returns false if theme is not used" do
      expect(pot1.theme_used?("Purple", user.id)).to be false
    end

    it "ignores its own theme when checking" do
      expect(pot1.theme_used?("Green", user.id)).to be false
    end
  end
end
