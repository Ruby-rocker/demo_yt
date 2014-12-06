class Settings::DashboardController < ApplicationController

  before_filter :check_super_user

  def index
  end

  private ############################

  def check_super_user
    #redirect_to root_path, alert: 'Unauthorized' if current_tenant.is_inactive?
    redirect_to root_path, alert: 'Unauthorized' unless current_user.is_super_user?
  end

end
