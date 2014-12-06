class SubscriptionMailer < ActionMailer::Base
  default from: "\"YesTrak Notification!\" <notice@yestrak.com>"

  def subscription_status_change(new_status, user)
    ActsAsTenant.current_tenant = nil
    @new_status = new_status
    @user = user

    mail(subject: 'Monthly Subscription', to: user.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def subscription_status_change_dev(old_status, new_status, user, kind)
    ActsAsTenant.current_tenant = nil
    @old_status = old_status
    @new_status = new_status
    @user = user
    @kind = kind
    @now = Time.now
    mail(subject: 'Monthly Subscription', to: "#{APP_CONFIG['developer_emails']}")
  end

    #Billing Notifications

  def billing_info_modified(billing_info)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    mail(subject: 'Billing Information Modified', to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def monthly_upgrade_downgrade(billing_info)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    mail(subject: 'Your Account Has Been Upgraded', to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def monthly_upgrade_downgrade_2(billing_info)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    mail(subject: 'Your Account Has Been Downgraded', to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def user_subscription_cancelled(tenant)
    ActsAsTenant.current_tenant = nil
    @tenant = tenant
    mail(subject: 'Subscription Cancelled', to: @tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}, #{APP_CONFIG['head_email']}")
  end

  def monthly_subscription_renewed(billing_info)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    mail(subject: 'Monthly Subscription Renewed', to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def monthly_subscription_active(billing_info)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    mail(subject: 'Your Monthly Subscription is Active', to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def monthly_subscription_unsuccessful(billing_info, tenant)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    @tenant = tenant
    @days = (tenant.block_date - Date.today).to_i
    mail(subject: 'Monthly Subscription Unsuccessful', to: tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def payment_unsuccessful(billing_info,days)
    ActsAsTenant.current_tenant = nil
    @billing_info = billing_info
    @days = days
    if @billing_info.tenant.plan_bid.eql? PackageConfig::PAY_AS_YOU_GO
      @plan_name = "Pay As You Go"
    elsif @billing_info.tenant.plan_bid.eql? PackageConfig::MINUTE_200
      @plan_name = "200 Minutes"
    elsif @billing_info.tenant.plan_bid.eql? PackageConfig::MINUTE_500
      @plan_name = "500 Minutes"
    end

    mail(subject: "#{@plan_name} Payment Unsuccessful", to: @billing_info.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def billing_enhancements(name,email)
    ActsAsTenant.current_tenant = nil
    @name = name.capitalize
    mail(subject: "Subscription Billing Enhancements", to: email, bcc: "mayank.jani@softwebsolutions.com,shweta.aagja@softwebsolutions.com", template_path: 'subscription_mailer', template_name: 'billing_enhancements')
  end
end
