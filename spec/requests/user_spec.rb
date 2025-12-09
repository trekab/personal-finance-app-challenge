require 'rails_helper'

RSpec.describe "Users", type: :request do
  # Mock the User model for testing purposes
  # Note: In request specs, we typically interact with the actual database,
  # but for speed, we can still use mocks for User.new if desired.
  let(:valid_attributes) {
    {
      name: "Test User",
      email_address: "test@example.com",
      password: "password"
    }
  }

  let(:invalid_attributes) {
    # Assuming email_address and password validation will fail here
    {
      name: "Invalid",
      email_address: "invalid_email",
      password: "short" # Assuming password < 8 chars is invalid
    }
  }

  # We will rely on the actual User model validation in request specs for accuracy
  # and only mock the errors object for checking the JSON response format easily.

  # --- GET #new ---
  describe "GET /new" do
    it "renders a successful response" do
      # Use the path helper for the new action
      get new_user_path
      expect(response).to have_http_status(:ok)
    end

    # 💥 Fix for render_template error 💥
    it "renders the signup form (checks content instead of template)" do
      get new_user_path
      # Check for a specific element or text that confirms the new template loaded
      expect(response.body).to include("Create Account") # Replace with actual form title/text
      expect(response.body).to include("user[email_address]")
    end
  end

  # --- POST #create ---
  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        # Verify that the count changes after the post
        expect {
          post users_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it "redirects to the root path" do
        post users_path, params: { user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      # 💥 Fix for flash/notice check 💥
      it "sets a notice in the flash hash" do
        post users_path, params: { user: valid_attributes }
        # Access flash directly on the response object
        expect(flash[:notice]).to eq("You have successfully signed up.")
      end

      it "responds with status :created for JSON format" do
        # 💥 Fix for MissingTemplate error 💥
        # We assume the controller was updated to: format.json { render json: @user, status: :created }
        post users_path, params: { user: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include("application/json")
        expect(JSON.parse(response.body)).to include("id") # Check that the user data is returned
      end
    end

    context "with invalid parameters" do
      it "does not save the new user" do
        expect {
          post users_path, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      # 💥 Fix for render_template error 💥
      it "returns an unprocessable entity status (HTML)" do
        post users_path, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      # 💥 Fix for JSON error check 💥
      it "responds with status :unprocessable_content and returns errors for JSON" do
        post users_path, params: { user: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_content)

        json_body = JSON.parse(response.body)

        # Check for specific error keys (based on your User model validations)
        expect(json_body).to include("password")
      end
    end
  end
end
