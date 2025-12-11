class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  before_action :set_current_user, if: :authenticated?

  def set_current_user
    if session[:user_id]
      Current.user = User.unscoped.find(session[:user_id])
    end
    start_new_session_for(Current.user) unless resume_session
  end

  def current_user
    Current.user
  end
end
