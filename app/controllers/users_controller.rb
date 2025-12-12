class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  layout "auth"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        flash[:notice] = "You have successfully signed up."
        format.html { redirect_to root_path, notice: "You have successfully signed up." }
        format.json { render json: @user, status: :created }
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @user.errors, status: :unprocessable_content }
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(user: [ :name, :email_address, :password ])
  end
end
