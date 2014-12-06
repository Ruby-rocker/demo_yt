class UsersController < ApplicationController
	load_and_authorize_resource

  skip_before_filter :logged_in, :set_defaults, :set_current_tenant, only: :login

  def edit_user_password
	end

	def update_user_password
		current_user.password = params[:user][:password]
		current_user.save!(validate: false)
    current_user.notifications.create(title: 'You have changed your user password', notify_on: Time.now,
      content: "<span>The user password for #{current_user.full_name} has been changed. If you do not recognize this change, please contact Customer Care immediately.</span>")
		redirect_to users_edit_user_password_path, notice: "Password updated successfully"
	end

	def check_current_password
		render text: User.find(current_user.id).valid_password?(params[:user][:current_password])
  end

  def login
    user = User.find_by_authentication_token(params[:auth_token])
    if user
      sign_in(user)
      user.reset_authentication_token!
    else
      sign_out(current_user)
    end
    redirect_to root_path
  end
end