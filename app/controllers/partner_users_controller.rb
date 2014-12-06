class PartnerUsersController < ApplicationController
  layout 'partners'
  #load_and_authorize_resource

  skip_before_filter :logged_in, :set_defaults, :set_current_tenant

  def edit_user_password
  end

  def update_user_password
    current_partner_master.password = params[:partner_user][:password]
    current_partner_master.save!(validate: false)
    redirect_to partner_users_edit_user_password_path, notice: "Password updated successfully"
  end

  def check_current_password
    render text: PartnerMaster.find(current_partner_master.id).valid_password?(params[:partner_user][:current_password])
  end
  def login
    partner = PartnerMaster.find_by_authentication_token(params[:auth_token])
    if partner
      sign_in(partner)
      partner.reset_authentication_token!
    else
      sign_out(current_partner_master)
    end
    redirect_to partners_dashboard_index_path
  end
end
