require "rails_helper"

RSpec.describe TransactionsHelper, type: :helper do
  describe "#transaction_amount" do
    let(:transaction) { double(:transaction, amount: 100.0, transaction_type: transaction_type) }

    context "when transaction_type is 'expense'" do
      let(:transaction_type) { "expense" }

      it "returns the negative amount" do
        expect(helper.transaction_amount(transaction)).to eq(-100.0)
      end
    end

    context "when transaction_type is 'withdraw'" do
      let(:transaction_type) { "withdraw" }

      it "returns the negative amount" do
        expect(helper.transaction_amount(transaction)).to eq(-100.0)
      end
    end

    context "when transaction_type is something else (e.g., 'income')" do
      let(:transaction_type) { "income" }

      it "returns the positive amount" do
        expect(helper.transaction_amount(transaction)).to eq(100.0)
      end
    end

    context "when amount is a decimal" do
      let(:transaction) { double(:transaction, amount: 12.34, transaction_type: transaction_type) }
      let(:transaction_type) { "expense" }

      it "handles decimals correctly" do
        expect(helper.transaction_amount(transaction)).to eq(-12.34)
      end
    end
  end
end
