require 'rails_helper'

RSpec.describe PasswordsController, type: :request do
  describe 'GET #new' do
    it 'returns a successful response' do
      get new_password_path
      expect(response).to be_successful
    end

    it 'returns http status 200' do
      get new_password_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows unauthenticated access' do
      get new_password_path
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, email_address: 'users@example.com') }
    let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(PasswordsMailer).to receive(:reset).and_return(mailer)
      allow(mailer).to receive(:deliver_later)
    end

    context 'when users exists' do
      it 'sends password reset email' do
        expect(PasswordsMailer).to receive(:reset).with(user)
        expect(mailer).to receive(:deliver_later)

        post passwords_path, params: { email_address: user.email_address }
      end

      it 'redirects to new session path' do
        post passwords_path, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets a notice message' do
        post passwords_path, params: { email_address: user.email_address }
        follow_redirect!
        expect(response.body).to include('Password reset instructions sent')
      end
    end

    context 'when users does not exist' do
      it 'does not send email' do
        expect(PasswordsMailer).not_to receive(:reset)

        post passwords_path, params: { email_address: 'nonexistent@example.com' }
      end

      it 'still redirects to new session path' do
        post passwords_path, params: { email_address: 'nonexistent@example.com' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'shows same notice message for security' do
        post passwords_path, params: { email_address: 'nonexistent@example.com' }
        follow_redirect!
        expect(response.body).to include('Password reset instructions sent')
      end
    end

    context 'rate limiting' do
      it 'allows requests within rate limit' do
        9.times do
          post passwords_path, params: { email_address: user.email_address }
        end

        post passwords_path, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:token) { 'valid_token' }

    before do
      allow(User).to receive(:find_by_password_reset_token!).with(token).and_return(user)
    end

    it 'returns a successful response' do
      get edit_password_path(token)
      expect(response).to be_successful
    end

    it 'returns http status 200' do
      get edit_password_path(token)
      expect(response).to have_http_status(:ok)
    end

    context 'with invalid token' do
      before do
        allow(User).to receive(:find_by_password_reset_token!)
                         .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it 'redirects to new password path' do
        get edit_password_path('invalid_token')
        expect(response).to redirect_to(new_password_path)
      end

      it 'sets an alert message' do
        get edit_password_path('invalid_token')
        follow_redirect!
        expect(response.body).to include('Password reset link is invalid or has expired')
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:token) { 'valid_token' }
    let!(:session1) { create(:session, user: user) }
    let!(:session2) { create(:session, user: user) }

    before do
      allow(User).to receive(:find_by_password_reset_token!).with(token).and_return(user)
    end

    context 'with valid password' do
      let(:valid_params) do
        { token: token, password: 'newpassword123', password_confirmation: 'newpassword123' }
      end

      it 'updates the users password' do
        allow(user).to receive(:update).and_call_original

        patch password_path(token), params: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'destroys all users sessions' do
        expect {
          patch password_path(token), params: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        }.to change { user.sessions.count }.from(2).to(0)
      end

      it 'redirects to new session path' do
        patch password_path(token), params: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets a notice message' do
        patch password_path(token), params: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        follow_redirect!
        expect(response.body).to include('Password has been reset')
      end
    end

    context 'with invalid password' do
      let(:invalid_params) do
        { password: 'newpassword123', password_confirmation: 'differentpassword' }
      end

      it 'does not update the password' do
        original_digest = user.password_digest
        patch password_path(token), params: invalid_params
        expect(user.reload.password_digest).to eq(original_digest)
      end

      it 'redirects back to edit password path' do
        patch password_path(token), params: invalid_params
        expect(response).to redirect_to(edit_password_path(token))
      end

      it 'sets an alert message' do
        patch password_path(token), params: invalid_params
        follow_redirect!
        expect(response.body).to include('Passwords did not match')
      end
    end

    context 'with invalid token' do
      before do
        allow(User).to receive(:find_by_password_reset_token!)
                         .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it 'redirects to new password path' do
        patch password_path('invalid_token'), params: { password: 'newpass', password_confirmation: 'newpass' }
        expect(response).to redirect_to(new_password_path)
      end

      it 'sets an alert message' do
        patch password_path('invalid_token'), params: { password: 'newpass', password_confirmation: 'newpass' }
        follow_redirect!
        expect(response.body).to include('Password reset link is invalid or has expired')
      end
    end
  end
end
