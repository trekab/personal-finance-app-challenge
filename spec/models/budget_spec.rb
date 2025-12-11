require "rails_helper"

RSpec.describe Budget, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:maximum_spend) }
    it { should validate_numericality_of(:maximum_spend).is_greater_than(0) }

    it { should validate_presence_of(:theme) }
    it { should validate_presence_of(:category) }

    it "validates uniqueness of theme scoped to user" do
      create(:budget, user: user, theme: "Green")

      duplicate = build(:budget, user: user, theme: "Green")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:theme]).to include("is already used by another budget")
    end

    it "allows same theme for different users" do
      other_user = create(:user)
      create(:budget, user: user, theme: "Red")

      duplicate = build(:budget, user: other_user, theme: "Red")
      expect(duplicate).to be_valid
    end
  end

  describe "constants" do
    it "has the correct CATEGORIES" do
      expect(Budget::CATEGORIES).to include("Entertainment", "Bills", "General")
      expect(Budget::CATEGORIES.size).to eq(10)
    end

    it "has the correct THEMES" do
      expect(Budget::THEMES).to match_array(%w[Green Yellow Cyan Navy Red Purple])
    end

    it "has the correct COLOR_MAP" do
      expect(Budget::COLOR_MAP["Green"]).to eq("#2f7f6b")
      expect(Budget::COLOR_MAP.keys).to match_array(Budget::THEMES)
    end
  end

  describe ".used_themes" do
    it "returns themes for the given user" do
      create(:budget, user: user, theme: "Green")
      create(:budget, user: user, theme: "Red")

      expect(Budget.used_themes(nil, user.id)).to match_array(["Green", "Red"])
    end

    it "excludes the given budget id" do
      b1 = create(:budget, user: user, theme: "Yellow")
      b2 = create(:budget, user: user, theme: "Purple")

      expect(Budget.used_themes(b1.id, user.id)).to eq(["Purple"])
    end
  end

  describe ".available_themes" do
    it "returns available themes for the user" do
      create(:budget, user: user, theme: "Green")

      expect(Budget.available_themes(nil, user.id))
        .to match_array(%w[Yellow Cyan Navy Red Purple])
    end

    it "excludes themes used by all budgets except the given id" do
      b1 = create(:budget, user: user, theme: "Green")
      b2 = create(:budget, user: user, theme: "Red")

      # If editing b2, only Green remains blocked
      expect(Budget.available_themes(b2.id, user.id))
        .to match_array(%w[Yellow Cyan Navy Purple] + ["Red"]) # Red becomes available for itself
    end
  end

  describe "#theme_used?" do
    it "returns true if theme is used by another budget for the same user" do
      create(:budget, user: user, theme: "Green")
      budget = create(:budget, user: user, theme: "Red")

      expect(budget.theme_used?("Green", user.id)).to be true
    end

    it "returns false if theme is not used by another budget" do
      create(:budget, user: user, theme: "Purple")
      budget = create(:budget, user: user, theme: "Red")

      expect(budget.theme_used?("Green", user.id)).to be false
    end

    it "does not count itself" do
      budget = create(:budget, user: user, theme: "Green")

      expect(budget.theme_used?("Green", user.id)).to be false
    end
  end
end
