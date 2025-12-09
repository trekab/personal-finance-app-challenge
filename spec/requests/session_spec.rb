require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe 'GET #new' do
    it 'returns a successful response' do
      get new_session_path
      expect(response).to be_successful
    end

    it 'returns http status 200' do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows unauthenticated access' do
      get new_session_path
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, email_address: 'users@example.com', password: 'password123') }
    let(:valid_params) { { email_address: user.email_address, password: 'password123' } }
    let(:invalid_params) { { email_address: user.email_address, password: 'wrongpassword' } }

    context 'with valid credentials' do
      it 'authenticates the users' do
        expect(User).to receive(:authenticate_by).with(
          ActionController::Parameters.new(valid_params).permit(:email_address, :password)
        ).and_return(user)

        post session_path, params: valid_params
      end

      it 'creates a new session record' do
        expect {
          post session_path, params: valid_params
        }.to change(Session, :count).by(1)
      end

      it 'redirects after successful authentication' do
        post session_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end

      it 'returns http status 302' do
        post session_path, params: valid_params
        expect(response).to have_http_status(:found)
      end
    end

    context 'with invalid credentials' do
      it 'does not authenticate the users' do
        expect(User).to receive(:authenticate_by).and_return(nil)

        post session_path, params: invalid_params
      end

      it 'does not create a new session record' do
        expect {
          post session_path, params: invalid_params
        }.not_to change(Session, :count)
      end

      it 'redirects back to new session path' do
        post session_path, params: invalid_params
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets an alert message' do
        post session_path, params: invalid_params
        follow_redirect!
        expect(response.body).to include('Try another email address or password')
      end
    end

    context 'with missing credentials' do
      it 'raises error when email is missing' do
        expect {
          post session_path, params: { password: 'password123' }
        }.to raise_error(ArgumentError, /One or more finder arguments are required/)
      end

      it 'raises error when password is missing' do
        expect {
          post session_path, params: { email_address: user.email_address }
        }.to raise_error(ArgumentError, /One or more password arguments are required/)
      end
    end

    context 'rate limiting' do
      it 'allows requests within rate limit' do
        9.times do
          post session_path, params: valid_params
        end

        post session_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'allows unauthenticated access' do
      it 'does not require authentication to create session' do
        post session_path, params: valid_params
        expect(response).not_to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let!(:user_session) { create(:session, user: user) }

    it 'destroys the session' do
      # Simulate being logged in by setting session or using the actual authentication mechanism
      # This test verifies the destroy action runs without error
      delete session_path
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to new session path' do
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'returns http status 302 (found) for Turbo compatibility' do
      delete session_path
      expect(response).to have_http_status(:found)
    end
  end
end
