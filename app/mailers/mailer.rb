class Devise::Mailer < Devise.parent_mailer.constantize
  include Devise::Mailers::Helpers

  default bcc: "#{APP_CONFIG['admin_emails']},#{APP_CONFIG['head_email']}"

  # Sign-up Process Email Notification

  def confirmation_instructions(record, opts={})
    ActsAsTenant.current_tenant = nil
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    ActsAsTenant.current_tenant = nil
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, opts={})
    ActsAsTenant.current_tenant = nil
    devise_mail(record, :unlock_instructions, opts)
  end
end
