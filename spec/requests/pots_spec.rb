require "rails_helper"

RSpec.describe "/pots", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:pot) { create(:pot, user: user) }

  # Stub Current.session.user and current_user for all requests
  before do
    fake_session = double("Session", user: user)
    allow(Current).to receive(:session).and_return(fake_session)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns a successful response" do
      get pots_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_pot_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    context "when user owns the pot" do
      it "returns a successful response" do
        get edit_pot_path(pot)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user does NOT own the pot" do
      let(:forbidden_pot) { create(:pot, user: other_user) }

      it "redirects to home with alert" do
        get edit_pot_path(forbidden_pot)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized")
      end
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        pot: {
          pot_name: "My Pot",
          target: 5000,
          theme: "Green"
        }
      }
    end

    let(:invalid_params) do
      {
        pot: {
          pot_name: "",
          target: nil,
          theme: ""
        }
      }
    end

    context "with valid parameters" do
      it "creates a pot and redirects" do
        expect {
          post pots_path, params: valid_params
        }.to change(Pot, :count).by(1)

        expect(response).to redirect_to(pots_path)
        expect(flash[:notice]).to eq("Pot was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "renders new with status 422" do
        post pots_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    let(:update_params) do
      {
        pot: {
          pot_name: "Updated Name",
          target: 2000,
          theme: "Yellow"
        }
      }
    end

    context "when user owns the pot" do
      it "updates and redirects to show" do
        patch pot_path(pot), params: update_params

        expect(response).to redirect_to(pot_path(pot))
        expect(flash[:notice]).to eq("Pot was successfully updated.")

        pot.reload
        expect(pot.pot_name).to eq("Updated Name")
        expect(pot.theme).to eq("Yellow")
      end
    end

    context "when user does NOT own the pot" do
      let(:other_pot) { create(:pot, user: other_user) }

      it "returns forbidden (HTML)" do
        patch pot_path(other_pot), params: update_params
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with invalid parameters" do
      it "renders edit with 422" do
        patch pot_path(pot), params: { pot: { pot_name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:pot) { create(:pot, user: user) }

    it "destroys the pot and redirects" do
      expect {
        delete pot_path(pot)
      }.to change(Pot, :count).by(-1)

      expect(response).to redirect_to(pots_path)
      expect(flash[:notice]).to eq("Pot was successfully destroyed.")
    end
  end

  describe "GET /:id/initiate_delete" do
    it "loads the view successfully" do
      get initiate_delete_pot_path(pot)
      expect(response).to have_http_status(:ok)
    end
  end
end
