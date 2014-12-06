class ContactMailer < ActionMailer::Base
  default from: "\"YesTrak Notification!\" <notice@yestrak.com>"

  def create_notice(user_id)
    ActsAsTenant.current_tenant = nil
    @resource = User.select('email,first_name,last_name').where(id:user_id).first
    mail(to: @resource.email, subject: 'New Contact Created')
  end

end
