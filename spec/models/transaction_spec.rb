require "rails_helper"

RSpec.describe Transaction, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "enums" do
    it {
      should define_enum_for(:transaction_type)
               .with_values(deposit: 0, withdraw: 1, expense: 2, income: 3)
               .backed_by_column_of_type(:integer)
    }

    it "validates presence of a valid enum value" do
      transaction = build(:transaction, transaction_type: nil)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include("can't be blank")
    end
  end

  describe "validations" do
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount) }
    it { should validate_presence_of(:transaction_type) }
  end

  describe ".search" do
    let(:user) { create(:user) }

    let!(:t1) { create(:transaction, user:, category: "Groceries", transaction_type: :expense) }
    let!(:t2) { create(:transaction, user:, category: "Salary", transaction_type: :income) }
    let!(:t3) { create(:transaction, user:, category: "Bank Deposit", transaction_type: :deposit) }
    let!(:t4) { create(:transaction, user:, category: "Cash Withdrawal", transaction_type: :withdraw) }

    context "when the search term is blank" do
      it "returns all transactions" do
        expect(Transaction.search(nil)).to match_array([t1, t2, t3, t4])
        expect(Transaction.search("")).to match_array([t1, t2, t3, t4])
      end
    end

    context "when searching by category" do
      it "returns matching records (case-insensitive)" do
        result = Transaction.search("gro")
        expect(result).to contain_exactly(t1)
      end
    end

    context "when searching by enum type" do
      it "matches 'deposit'" do
        result = Transaction.search("dep")
        expect(result).to contain_exactly(t3)
      end

      it "matches 'withdraw'" do
        result = Transaction.search("with")
        expect(result).to contain_exactly(t4)
      end

      it "matches 'expense'" do
        result = Transaction.search("exp")
        expect(result).to contain_exactly(t1)
      end

      it "matches 'income'" do
        result = Transaction.search("inc")
        expect(result).to contain_exactly(t2)
      end
    end

    context "when search term matches both category and type" do
      let!(:another_expense) { create(:transaction, user:, category: "Unexpected Expense", transaction_type: :expense) }

      it "returns all matching records" do
        result = Transaction.search("expense")
        expect(result).to match_array([t1, another_expense])
      end
    end

    context "when no matches exist" do
      it "returns an empty relation" do
        expect(Transaction.search("xyz")).to be_empty
      end
    end
  end
end
