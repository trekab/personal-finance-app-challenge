require "rails_helper"

RSpec.describe "BudgetsController", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:valid_attributes) do
    {
      category: "Entertainment",
      maximum_spend: 1000,
      theme: "Green"
    }
  end

  let(:invalid_attributes) do
    {
      category: "",
      maximum_spend: -10,
      theme: ""
    }
  end

  # Stub Current.session.user and current_user for all requests
  before do
    fake_session = double("Session", user: user)
    allow(Current).to receive(:session).and_return(fake_session)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      create(:budget, user: user)
      get budgets_path
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      budget = create(:budget, user: user)
      get budget_path(budget)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_budget_path
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      budget = create(:budget, user: user)
      get edit_budget_path(budget)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Budget" do
        expect {
          post budgets_path, params: { budget: valid_attributes }
        }.to change(Budget, :count).by(1)
      end

      it "redirects to the budgets list with notice" do
        post budgets_path, params: { budget: valid_attributes }
        expect(response).to redirect_to(budgets_path)
        follow_redirect!
        expect(response.body).to include("Budget was successfully created")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Budget" do
        expect {
          post budgets_path, params: { budget: invalid_attributes }
        }.not_to change(Budget, :count)
      end

      it "renders new with unprocessable_content status" do
        post budgets_path, params: { budget: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    let(:budget) { create(:budget, user: user, theme: "Green") }

    context "with valid parameters" do
      let(:new_attributes) { { category: "Bills", maximum_spend: 2000, theme: "Red" } }

      it "updates the requested budget" do
        patch budget_path(budget), params: { budget: new_attributes }
        budget.reload
        expect(budget.category).to eq("Bills")
        expect(budget.maximum_spend).to eq(2000)
        expect(budget.theme).to eq("Red")
      end

      it "redirects to budgets_path with notice" do
        patch budget_path(budget), params: { budget: new_attributes }
        expect(response).to redirect_to(budgets_path)
        follow_redirect!
        expect(response.body).to include("Budget was successfully updated")
      end
    end

    context "with invalid parameters" do
      it "renders edit with unprocessable_content status" do
        patch budget_path(budget), params: { budget: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested budget" do
      budget = create(:budget, user: user)
      expect {
        delete budget_path(budget)
      }.to change(Budget, :count).by(-1)
    end

    it "redirects to budgets list with notice" do
      budget = create(:budget, user: user)
      delete budget_path(budget)
      expect(response).to redirect_to(budgets_path)
      follow_redirect!
      expect(response.body).to include("Budget was successfully destroyed")
    end
  end

  describe "GET /initiate_delete" do
    it "renders a successful response" do
      budget = create(:budget, user: user)
      get initiate_delete_budget_path(budget)
      expect(response).to be_successful
    end
  end

  describe "authorization" do
    it "prevents other users from editing someone else's budget" do
      budget = create(:budget, user: other_user)
      get edit_budget_path(budget)
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  end
end
