require "rails_helper"

RSpec.describe "Transactions", type: :request do
  let(:user) { create(:user) }

  # Stub Current.session.user and current_user for all requests
  before do
    fake_session = double("Session", user: user)
    allow(Current).to receive(:session).and_return(fake_session)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /transactions" do
    let!(:t1) { create(:transaction, user:, category: "Groceries", amount: 50, date: 2.days.ago, transaction_type: :expense) }
    let!(:t2) { create(:transaction, user:, category: "Salary", amount: 5000, date: 5.days.ago, transaction_type: :income) }
    let!(:t3) { create(:transaction, user:, category: "Bills", amount: 200, date: 1.day.ago, transaction_type: :withdraw) }

    it "returns a successful response" do
      get transactions_path
      expect(response).to have_http_status(:ok)
    end

    def transaction_rows
      Nokogiri::HTML(response.body).css("tbody").text
    end

    context "search filter" do
      it "filters by search term" do
        get transactions_path, params: { search: "gro" }

        rows = transaction_rows
        expect(rows).to include("Groceries")
        expect(rows).not_to include("Bills")
        expect(rows).not_to include("Salary")
      end
    end

    context "category filter" do
      it "filters by category" do
        get transactions_path, params: { category: "Bills" }

        rows = transaction_rows
        expect(rows).to include("Bills")
        expect(rows).not_to include("Groceries")
        expect(rows).not_to include("Salary")
      end

      it "returns all when category is All" do
        get transactions_path, params: { category: "All" }

        rows = transaction_rows
        expect(rows).to include("Groceries")
        expect(rows).to include("Bills")
        expect(rows).to include("Salary")
      end
    end

    context "sorting" do
      it "sorts by latest (default)" do
        get transactions_path
        rows = transaction_rows

        expect(rows.index("Bills")).to be < rows.index("Groceries")
        expect(rows.index("Groceries")).to be < rows.index("Salary")
      end

      it "sorts by oldest" do
        get transactions_path, params: { sort: "oldest" }
        rows = transaction_rows

        expect(rows.index("Salary")).to be < rows.index("Groceries")
        expect(rows.index("Groceries")).to be < rows.index("Bills")
      end

      it "sorts by highest amount" do
        get transactions_path, params: { sort: "highest" }
        rows = transaction_rows

        expect(rows.index("Salary")).to be < rows.index("Bills")
        expect(rows.index("Bills")).to be < rows.index("Groceries")
      end

      it "sorts by lowest amount" do
        get transactions_path, params: { sort: "lowest" }
        rows = transaction_rows

        expect(rows.index("Groceries")).to be < rows.index("Bills")
        expect(rows.index("Bills")).to be < rows.index("Salary")
      end
    end
  end

  describe "GET /transactions/new" do
    it "renders a new transaction form" do
      get new_transaction_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New Transaction").or include("<form")
    end

    it "sets transaction_type from params" do
      get new_transaction_path, params: { transaction_type: "expense" }
      expect(response.body).to include('value="expense"').or include('selected="selected"')
    end

    it "sets customizable fields when provided" do
      get new_transaction_path, params: { customizable_type: "Pot", customizable_id: 42 }

      expect(response.body).to include('value="Pot"')
      expect(response.body).to include('value="42"')
    end
  end

  describe "POST /transactions" do
    let(:valid_params) do
      {
        transaction: {
          category: "Groceries",
          amount: 10,
          date: Date.today,
          transaction_type: "expense"
        }
      }
    end

    let(:invalid_params) do
      {
        transaction: {
          category: "",
          amount: "",
          date: "",
          transaction_type: ""
        }
      }
    end

    context "with valid params" do
      it "creates a transaction" do
        expect { post transactions_path, params: valid_params }.to change(Transaction, :count).by(1)
      end

      it "assigns current_user" do
        post transactions_path, params: valid_params
        expect(Transaction.last.user).to eq(user)
      end

      it "redirects back with fallback" do
        post transactions_path, params: valid_params
        expect(response).to redirect_to(transactions_path)
      end

      it "returns JSON success" do
        post transactions_path, params: valid_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "does not create a transaction" do
        expect { post transactions_path, params: invalid_params }.not_to change(Transaction, :count)
      end

      it "renders new with 422" do
        post transactions_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns JSON errors" do
        post transactions_path, params: invalid_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end
end
