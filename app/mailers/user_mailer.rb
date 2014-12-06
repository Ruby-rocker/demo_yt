#class UserMailer < ActionMailer::Base
class UserMailer < Devise::Mailer

  default from: "\"Welcome to YesTrak!\" <welcome@yestrak.com>"

  #def confirmation_instructions(record, opts={})
  #You will receive an email with instructions about how to reset your password in a few minutes.
  #  super
  #end

  def confirmation_instructions(record, opts={})
    ActsAsTenant.current_tenant = nil
    if record.class.name == "PartnerMaster"
      opts = {
          :subject => "Your YesTrak partner portal is ready for set-up",
          :bcc => "#{APP_CONFIG['admin_emails']},#{APP_CONFIG['head_email']}"
      }
    else
      if record.role == 1
        opts = {
            :bcc => "#{APP_CONFIG['admin_emails']},#{APP_CONFIG['head_email']}"
        }
      elsif record.role == 2
        opts = {
            :subject => "You have been added as a Administrator to #{record.tenant.subdomain}",
            :bcc => "#{APP_CONFIG['admin_emails']},#{APP_CONFIG['head_email']}"
        }
      elsif record.role == 3
        opts = {
            :subject => "You have been added as a User to #{record.tenant.subdomain}",
            :bcc => "#{APP_CONFIG['admin_emails']},#{APP_CONFIG['head_email']}"
        }
      end
    end
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    ActsAsTenant.current_tenant = nil
    devise_mail(record, :reset_password_instructions, opts)
  end

  # Sign-up Process Email Notification

  def subscription_notice(user_id, subscription_id, transaction_id)
    ActsAsTenant.current_tenant = nil
    @user = User.select('email,first_name,last_name,confirmation_token,plan_bid,created_at').where(id:user_id).first
    @subscription = Subscription.select('status').where(id:subscription_id).first
    @transaction = BillingTransaction.select('transaction_bid,amount,billing_period_start_date,billing_period_end_date').where(id:transaction_id).first

    mail(from: "\"YesTrak Notification!\" <welcome@yestrak.com>", to: @user.email,
         subject: 'Thanks for subscribing to YesTrak', bcc: "#{APP_CONFIG['admin_emails']}, #{APP_CONFIG['head_email']}")
  end

  def cancellation_notice(current_user)
    ActsAsTenant.current_tenant = nil
    @tenant_cancellation = TenantCancellation.find_by_tenant_id(current_user.tenant_id)
    email = @tenant_cancellation.tenant.owner.email
    mail(from: "\"YesTrak Notification!\" <notice@yestrak.com>", to: email, subject: 'Suggestion for Yestrak', bcc: "#{APP_CONFIG['admin_emails']}, #{APP_CONFIG['head_email']}")
  end

  # Sign-up Process Email Notification

  def account_info_notice(user)
    ActsAsTenant.current_tenant = nil
    @user = user
    mail(from: "\"YesTrak Notification!\" <welcome@yestrak.com>", to: "#{@user.email}",
         subject: 'Account Information', bcc: "#{APP_CONFIG['admin_emails']}, #{@user.tenant.owner.email}")
  end

  def account_info_notice_partner(user)
    ActsAsTenant.current_tenant = nil
    @user = user
    mail(from: "\"YesTrak Notification!\" <welcome@yestrak.com>", to: "#{@user.email}",
         subject: 'Partner Account Information', bcc: "info@yestrak.com")
  end

  # Users Email Notifications

  def user_added(user)
    ActsAsTenant.current_tenant = nil
    @user = user
    mail(subject: "A new user was added to #{@user.tenant.subdomain}", to: "#{@user.tenant.owner.email}, #{@user.email}", bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def administrator_added(user)
    ActsAsTenant.current_tenant = nil
    @user = user
    mail(subject: "A new administrator was added to #{@user.tenant.subdomain}", to: @user.tenant.owner.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def user_deleted(created_at, timezone, full_name, email)
    ActsAsTenant.current_tenant = nil
    @created_at = created_at
    @timezone = timezone
    @full_name = full_name
    mail(subject: 'User Deleted', from: "\"YesTrak Notification\" <notice@yestrak.com>", to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def administrator_deleted(created_at, timezone, full_name, email)
    ActsAsTenant.current_tenant = nil
    @created_at = created_at
    @timezone = timezone
    @full_name = full_name
    mail(subject: 'Administrator Deleted', from: "\"YesTrak Notification\" <notice@yestrak.com>", to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def announcement(body, email)
    ActsAsTenant.current_tenant = nil
    @body = body
    mail(subject: 'Announcement', from: "\"YesTrak Customer Care\" <support@yestrak.com>", to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def partner_approval(email)
    ActsAsTenant.current_tenant = nil
    mail(subject: 'You are approved', from: "\"YesTrak Notification\" <notice@yestrak.com>", to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def agreement_uploaded(name)
    ActsAsTenant.current_tenant = nil
    @name = name
    mail(subject: 'Agreement uploaded', from: "\"YesTrak Notification\" <notice@yestrak.com>", to: "#{APP_CONFIG['admin_emails']}", bcc: 'zach@yestrak.com')
  end

  def you_just_signed(email)
    attachments['YesTrakPartnerAgreement.pdf'] = File.read('yestrak_partner_agreement.pdf')
    mail(subject: "You just signed YesTrak Partner Agreement", from: "\"YesTrak Notification\" <notice@yestrak.com>", to: email)
  end
end
