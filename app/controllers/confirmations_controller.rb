class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :logged_in, :set_current_tenant, :set_defaults
  
  def show
    if request.subdomain == PARTNER_SUBDOMAIN
      self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token]) if params[:confirmation_token].present?
      super if self.resource.nil? or self.resource.confirmed?
    else
      @tenant_id = params[:tenant_id]
      if @tenant_id.present?
        tenant = Tenant.find(@tenant_id)
      else
        user = User.find_by_confirmation_token(params[:confirmation_token])
        tenant = Tenant.find(user.tenant.id) if user.present?
      end
      tenant.set_as_active if tenant.present?
      self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token]) if params[:confirmation_token].present?
      redirect_to APP_CONFIG['pricing_page'] if self.resource && self.resource.role.eql?(User::OWNER) && self.resource.status != 'active'
      super if self.resource.nil? or self.resource.confirmed?
    end
  end

  def confirm
    if request.subdomain == PARTNER_SUBDOMAIN
      self.resource = resource_class.find_by_confirmation_token(params[resource_name][:confirmation_token]) if params[resource_name][:confirmation_token].present?
      if resource.update_attributes(params[resource_name].except(:confirmation_token)) && resource.password_match?
        self.resource = resource_class.confirm_by_token(params[resource_name][:confirmation_token])
        set_flash_message :notice, :confirmed
        sign_in(resource_name, resource)
        UserMailer.delay.account_info_notice_partner(self.resource)
        redirect_to embedded_signing_partners_partner_docusign_index_path
      else
        render :action => "show"
      end
    else
      @tenant_id = params[:tenant_id]
      if @tenant_id.present?
        tenant = Tenant.find(@tenant_id)
      else
        user = User.find_by_confirmation_token(params[resource_name][:confirmation_token])
        tenant = Tenant.find(user.tenant.id) if user.present?
      end
      tenant.set_as_active if tenant.present?

      self.resource = resource_class.find_by_confirmation_token(params[resource_name][:confirmation_token]) if params[resource_name][:confirmation_token].present?
      #redirect_to APP_CONFIG['pricing_page'] if resource && resource.status != 'active'

      if self.resource.role.eql?(User::OWNER)
        tenant = resource.tenant
        tenant.subdomain = params[:user][:subdomain]
        tenant.timezone = params[:account][:timezone]
        unless tenant.save
          error_msg = 1
          flash[:error] = tenant.errors
        end
        tenant.calendars.first.update_attributes({"timezone" => tenant.timezone})
        tenant.businesses.map{|business| business.address.update_attributes({"timezone" => tenant.timezone})}
      end

      if resource.update_attributes(params[resource_name].except(:confirmation_token)) && resource.password_match?
        self.resource = resource_class.confirm_by_token(params[resource_name][:confirmation_token])
        set_flash_message :notice, :confirmed
        #sign_in_and_redirect(resource_name, resource)
      else
        error_msg = 1
      end

      if error_msg.present?
        render :action => "show"
      else
        UserMailer.delay.account_info_notice(self.resource)
        # New Account Created
        tenant.notifications.create(title: 'New Account Created', notify_on: Time.now,
                                    content: "<span>The account #{tenant.subdomain} was created at #{Time.now.in_time_zone(tenant.timezone).strftime("%B %d, %Y at %l:%M%P")}. The owner of this account is #{tenant.owner.full_name}.</span>")
        url = "http://"
        redirect_to url.concat((tenant.subdomain).concat(".yestrak.com"))
      end
    end
  end
end