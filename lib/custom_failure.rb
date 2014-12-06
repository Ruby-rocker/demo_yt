class CustomFailure < Devise::FailureApp
  def redirect_url
    if params[:user] && params[:user][:email].present?
      @user = User.find_by_email(params[:user][:email])
      if @user && @user.is_owner? && !@user.active_for_authentication?
        rejoin_registrations_path(id: @user.id, token: @user.authentication_token)
      else
        super
      end
    else
      super
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end