class AdminMailer < ActionMailer::Base
  default from: "welcome@yestrak.com", to: APP_CONFIG['admin_emails']

  def subscription_notice(user_id)
    ActsAsTenant.current_tenant = nil
    @user = User.select('id,email,first_name,last_name,status,plan_bid,created_at,tenant_id').where(id:user_id).first

    mail(subject: 'New user Signed up')
  end

  def comment_created(comment_id)
    ActsAsTenant.current_tenant = nil
    @comment = ActiveAdmin::Comment.where(id: comment_id).first
    @help = Help.find(@comment.resource_id)

    mail(subject: 'In Response To Your YesTrak Question', from: "\"YesTrak Support Team\" <support@yestrak.com>", to: @help.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def credit_minutes_added(credit_minutes,subdomain,email,created_at,timezone)
    ActsAsTenant.current_tenant = nil
    @credit_minutes = credit_minutes
    @subdomain = subdomain
    @tenant_config_created_at = created_at
    @tenant_timezone = timezone
    mail(subject: 'You Received A Credit!', from: "\"YesTrak Support Team\" <support@yestrak.com>", to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def admin_user_added(id, current_admin_user_email)
    ActsAsTenant.current_tenant = nil
    @admin_user = AdminUser.find(id)
    @email = @admin_user.email
    @created_at = @admin_user.created_at
    @current_admin_user_email = current_admin_user_email

    mail(subject: 'A User Has Been Added to Admin.YesTrak.Com', to: @email, bcc: "#{APP_CONFIG['admin_emails']}")
  end
end
