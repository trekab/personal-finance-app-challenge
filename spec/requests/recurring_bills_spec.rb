# spec/requests/recurring_bills_spec.rb
require 'rails_helper'

RSpec.describe "RecurringBills", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let!(:bill1) { create(:recurring_bill, user: user, bill_title: "Electricity", amount: 100, next_due_date: Date.today + 2.days) }
  let!(:bill2) { create(:recurring_bill, user: user, bill_title: "Water", amount: 50, next_due_date: Date.today + 5.days) }
  let!(:bill3) { create(:recurring_bill, user: other_user, bill_title: "Internet", amount: 80) }

  before do
    fake_session = double("Session", user: user)
    allow(Current).to receive(:session).and_return(fake_session)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /recurring_bills" do
    it "returns http success" do
      get recurring_bills_path
      expect(response).to have_http_status(:ok)
    end

    it "displays only current_user's bills" do
      get recurring_bills_path
      expect(response.body).to include("Electricity")
      expect(response.body).to include("Water")
      expect(response.body).not_to include("Internet")
    end

    context "with search param" do
      it "filters by bill_title" do
        get recurring_bills_path, params: { search: "Electric" }
        expect(response.body).to include("Electricity")
        expect(response.body).not_to include("Water")
      end
    end

    context "with sort param" do
      it "sorts by oldest" do
        get recurring_bills_path, params: { sort: "oldest" }
        expect(response.body.index("Electricity")).to be < response.body.index("Water")
      end

      it "sorts by highest amount" do
        get recurring_bills_path, params: { sort: "highest" }
        expect(response.body.index("Electricity")).to be < response.body.index("Water")
      end

      it "sorts by lowest amount" do
        get recurring_bills_path, params: { sort: "lowest" }
        expect(response.body.index("Water")).to be < response.body.index("Electricity")
      end

      it "sorts by bill_title ascending" do
        get recurring_bills_path, params: { sort: "asc" }
        expect(response.body.index("Electricity")).to be < response.body.index("Water")
      end

      it "sorts by bill_title descending" do
        get recurring_bills_path, params: { sort: "desc" }
        expect(response.body.index("Water")).to be < response.body.index("Electricity")
      end
    end

    it "displays totals" do
      get recurring_bills_path
      expect(response.body).to include(user.recurring_bills.sum(:amount).to_s)
      expect(response.body).to include(user.overdue_bills.to_s)
      expect(response.body).to include(user.upcoming_bills.to_s)
    end
  end

  describe "GET /recurring_bills/new" do
    it "returns http success and displays new form" do
      get new_recurring_bill_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("form")
    end
  end

  describe "POST /recurring_bills" do
    let(:valid_params) do
      {
        recurring_bill: {
          bill_title: "Internet",
          amount: 120,
          frequency_type: "Monthly",
          day_of_month: 5
        }
      }
    end

    let(:invalid_params) do
      {
        recurring_bill: {
          bill_title: "",
          amount: -50,
          frequency_type: ""
        }
      }
    end

    context "with valid params" do
      it "creates a new bill" do
        expect {
          post recurring_bills_path, params: valid_params
        }.to change(user.recurring_bills, :count).by(1)
      end

      it "redirects to index with notice" do
        post recurring_bills_path, params: valid_params
        follow_redirect!
        expect(response.body).to include("Recurring bill was successfully created.")
      end
    end

    context "with invalid params" do
      it "does not create a bill" do
        expect {
          post recurring_bills_path, params: invalid_params
        }.not_to change(user.recurring_bills, :count)
      end

      it "renders new with unprocessable_content" do
        post recurring_bills_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
