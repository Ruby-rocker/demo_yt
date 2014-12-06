class ClientMailer < ActionMailer::Base
  default from: "\"YesTrak Notification!\" <notice@yestrak.com>"

  def webhook(status, plan, kind, subscription)
    @status = status
    @plan = plan
    @kind = kind
    @subscription = subscription
    mail(subject: 'WEBHOOK Received staging', to: 'shweta.aagja@softwebsolutions.com')
  end

  def xps_call_data(date, time, count=nil)
    @date = date
    @time = time
    @count = count
    mail(subject: "staging XPS_CALL_DATA for #{date}", to: 'shweta.aagja@softwebsolutions.com')
  end

  def all_calls_received(call_detail_created_at, call_detail_call_from, phone_script_name, call_detail, emails)
    ActsAsTenant.current_tenant = nil
    @call_detail = call_detail
    @created_at = call_detail_created_at
    @call_from = call_detail_call_from
    @script_name = phone_script_name

    mail(subject: 'A Call Received', to: emails)
  end

  def all_calls_received_support(call_detail_created_at, call_detail_call_from, phone_script_name, call_detail, business_name)
    ActsAsTenant.current_tenant = nil
    @call_detail = call_detail
    @created_at = call_detail_created_at
    @call_from = call_detail_call_from
    @script_name = phone_script_name
    @business_name = business_name
    mail(subject: 'A Call Received', to: "#{APP_CONFIG['admin_emails']}")
  end

  def appointment_set(appointment_id, emails)
    ActsAsTenant.current_tenant = nil
    @appointment = Appointment.unscoped.find(appointment_id)
    @contact_name = @appointment.contact.full_name
    @phone_script_name = @appointment.phone_script.name
    @calendar_name = @appointment.calendar.name

    mail(subject: 'A New Appointment Set', to: emails, bcc: "#{APP_CONFIG['admin_emails']}")

  end

  def message_taken(note, contact, email)
    ActsAsTenant.current_tenant = nil
    @note = note
    @contact = contact
    @business_name = note.tenant.businesses.first.name
    @phone_script  = PhoneScript.find(note.phone_script_id)
    mail(subject: 'Message Taken Via Call Center', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def voicemail(call_detail_call_from, call_detail_created_at, url, time_zone, emails)
    ActsAsTenant.current_tenant = nil
    @time_zone = time_zone
    @call_from = call_detail_call_from
    @created_at = call_detail_created_at
    @url = url
    mail(subject: 'A New Voicemail Received', to: emails, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  #def script_deleted(phone_script)
  #  @phone_script = phone_script
  #
  #  mail(subject: 'Script Deleted', to: @phone_script.tenant.owner.email, bcc: "#{APP_CONFIG['developer_emails']}, #{APP_CONFIG['admin_emails']}")
  #end

  def script_deleted(phone_script)
    ActsAsTenant.current_tenant = nil
    @phone_script = phone_script

    mail(subject: 'A script has been cancelled', from: "\"YesTrak Call Center Support\" <support@yestrak.com>", to: "tmida@xpsservices.com, scharbonneau@xpsservices.com, htabbach@traverconnect.com, htabbach@xpsusa.com", bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def phone_greeting_uploaded(phone_script, email)
    ActsAsTenant.current_tenant = nil
    @phone_script = phone_script

    mail(subject: 'Phone Greeting Uploaded', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def new_script_active(phone_script_name, phone_script_created_at, name, emails, phone_script)
    ActsAsTenant.current_tenant = nil
    @phone_script = phone_script
    @script_name = phone_script_name
    @script_created_at = phone_script_created_at
    @name = name

    mail(subject: "Your script, #{@script_name}, is live!", to: emails, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def script_updated(phone_script_name, phone_script_created_at, phone_script_updated_at, script_id, phone_script, emails)
    ActsAsTenant.current_tenant = nil
    @script_name = phone_script_name
    @created_at = phone_script_created_at
    @updated_at = phone_script_updated_at
    @script_id = script_id
    @phone_script = phone_script

    mail(subject: 'Script Updated', to: emails, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def script_created(phone_script_name, phone_script_created_at, script_id, phone_script, emails)
    ActsAsTenant.current_tenant = nil
    @script_name = phone_script_name
    @created_at = phone_script_created_at
    @script_id = script_id
    @phone_script = phone_script

    mail(subject: 'A new script created', to: emails, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def sms_added_to_script(phone_script, email)
    ActsAsTenant.current_tenant = nil
    @phone_script = phone_script

    mail(subject: 'SMS # added to a script', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  # Calendar Email Notifications

  def google_sync_notification(cal)
    ActsAsTenant.current_tenant = nil
    @cal = cal
    email = cal.google_authentication_email
    @calendar_name = cal.name
    @google_calendar_name = cal.google_authentication_name
    @business_name = cal.business.name
    mail(subject: 'Sync With Google Calendar', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def google_sync_notification_cancel(cal, email, calendar_name, google_calendar_name, user_name)
    ActsAsTenant.current_tenant = nil
    @cal = cal
    email = email
    @calendar_name = calendar_name
    @google_calendar_name = google_calendar_name
    @user_name = user_name
    @business_name = cal.business.name
    mail(subject: 'Cancel Sync With Google Calendar', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def calendar_created(cal,email)
    ActsAsTenant.current_tenant = nil
    @cal = cal
    @calendar_name = cal.name
    @calendar_auth_token = cal.calendar_auth_token
    mail(subject: 'A new calendar has been created', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  def calendar_deleted(cal,email)
    ActsAsTenant.current_tenant = nil
    @cal = cal
    @calendar_name = cal.name
    mail(subject: 'A calendar has been deleted', to: email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  # Help Email Notification

  def help_notice(help_id)
    ActsAsTenant.current_tenant = nil
    @help = Help.find(help_id)
    mail(subject: 'YesTrak Help Form', to: @help.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end
  # Partner Help Email Notifications

  def partner_help_notice(partner_help_id)
    ActsAsTenant.current_tenant = nil
    @partner_help = PartnerHelp.find(partner_help_id)
    mail(subject: 'YesTrak Partner Help Form', to: @partner_help.email, bcc: "#{APP_CONFIG['admin_emails']}")
  end

  # Business Email Notifications

  def business_created(business)
    ActsAsTenant.current_tenant = nil
    @business = business
    mail(subject: 'Business Created', to: @business.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def business_updated(business)
    ActsAsTenant.current_tenant = nil
    @business = business
    mail(subject: 'Business Updated', to: @business.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def business_deleted(business)
    ActsAsTenant.current_tenant = nil
    @business = business
    mail(subject: 'Business Deleted', to: @business.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  # Contact Email Notifications

  def contacts_exported(tenant)
    ActsAsTenant.current_tenant = nil
    @tenant = tenant
    mail(subject: 'Contacts Exported', to: @tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def contacts_imported(tenant)
    ActsAsTenant.current_tenant = nil
    @tenant = tenant
    mail(subject: 'Contacts Imported', to: @tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  # Call recordings Notifications

  def call_recordings_subscribed(updated_at, timezone, email)
    ActsAsTenant.current_tenant = nil
    @updated_at = updated_at
    @timezone = timezone
    mail(subject: 'Call Recording Subscription Added', to: email, bcc: APP_CONFIG['admin_emails'])
  end

  def call_recordings_subscription_canceled(updated_at, timezone, email)
    ActsAsTenant.current_tenant = nil
    @updated_at = updated_at
    @timezone = timezone
    mail(subject: 'Call Recording Subscription Cancelled', to: email, bcc: APP_CONFIG['admin_emails'])
  end

  #Phone Menu Notifications

  def phone_menu_created(phone_menu)
    ActsAsTenant.current_tenant = nil
    @phone_menu = phone_menu
    mail(subject: 'Phone Menu Created', to: @phone_menu.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def phone_menu_cancelled(phone_menu)
    ActsAsTenant.current_tenant = nil
    @phone_menu = phone_menu
    @phone_menu_name = PhoneMenu.unscoped.find(@phone_menu.type_id).name
    mail(subject: 'Phone Menu Cancelled', to: @phone_menu.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def phone_menu_modified(phone_menu)
    ActsAsTenant.current_tenant = nil
    @phone_menu = phone_menu
    mail(subject: 'Phone Menu Modified', to: @phone_menu.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def phone_menu_added(phone_menu)
    ActsAsTenant.current_tenant = nil
    @phone_menu = phone_menu
    @phone_menu_name = phone_menu.name
    mail(subject: 'Phone Menu Added', to: @phone_menu.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  # Minutes are running low Notification

  def minutes_running_low(tenant)
    ActsAsTenant.current_tenant = nil
    @tenant = tenant
    @plan = tenant.plan_bid.to_s
    @days = (tenant.next_due - Date.today).to_i
    mail(subject: 'Minutes Running Low', to: @tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  #Voicemail Notifications

  def voicemail_added(voicemail)
    ActsAsTenant.current_tenant = nil
    @voicemail = voicemail
    mail(subject: 'Voicemail Added', to: @voicemail.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  def voicemail_cancelled(voicemail)
    ActsAsTenant.current_tenant = nil
    @voicemail = voicemail
    mail(subject: 'Voicemail Cancelled', to: @voicemail.tenant.owner.email, bcc: APP_CONFIG['admin_emails'])
  end

  # call transaction - log mailer
  def call_transaction_mailer(tenant,gate)
    ActsAsTenant.current_tenant = nil
    @tenant = tenant
    @gate = gate
    mail(subject: 'Call Transaction', to: 'mayank.jani@softwebsolutions.com')
  end
end
