module LongTasks
  extend self

  def release_twilio_number(phone_sid)
    if phone_sid.present?
      client = TwilioApi.new
      client.destroy(phone_sid)
    end
  end
  handle_asynchronously :release_twilio_number

  def send_sms_notice(from, to, body)
    client = TwilioApi.new
    client.send_sms(from, to, "YesTrak Notification: #{body}")
  end
  handle_asynchronously :send_sms_notice

  def update_on_call_complete(call_sid, subdomain)
    tenant = Tenant.find_using_subdomain(subdomain)
    record_duration = call_duration = 0
    ActsAsTenant.with_tenant(tenant) do
      call_detail = CallDetail.find_by_call_sid(call.sid)
      if call_detail
        client = TwilioApi.new
        call = client.call_log(call_sid)
        recording_sid = nil
        #url = nil
        call_detail.account_sid = call.account_sid
        call_detail.status = call.status
        call_detail.direction = call.direction
        call_detail.start_time = call.start_time
        call_detail.end_time = call.end_time
        call_detail.duration = call.duration
        call_detail.parent_call_sid = call.parent_call_sid
        call_detail.date_created = call.date_created
        call_detail.date_updated = call.date_updated
        call_detail.phone_number_sid = call.phone_number_sid
        call_detail.price = call.price
        call_detail.price_unit = call.price_unit
        call_detail.answered_by = call.answered_by
        call_detail.forwarded_from = call.forwarded_from
        call_detail.caller_name = call.caller_name
        call_detail.group_sid = call.group_sid

        twilio_number = call_detail.twilio_number
        phone_number = twilio_number.twilioable
        call_detail.callable = phone_number # PhoneScript/Voicemail/PhoneMenu
        call_detail.save
        call_duration += call_detail.duration.to_i
        client.record_by_call(call).each do |record|
          recording = Recording.find_or_initialize_by_recording_sid(record.sid)
          recording_sid = record.sid
          recording.duration = record.duration
          recording.url = 'http://api.twilio.com' + record.uri.split('.').first
          recording.account_sid = record.account_sid
          recording.call_sid = record.call_sid
          recording.date_created = record.date_created
          recording.date_updated = record.date_updated
          recording.save
          record_duration += recording.duration.to_i
        end
        # update call durations
        #twilio_number = call_detail.twilio_number
        #phone_number = twilio_number.twilioable
        if phone_number
          timestamp = call_detail.created_at.in_time_zone(phone_number.business.address.timezone).strftime('%b %d %Y, %I:%M%p')
          case phone_number.class.name
            when 'PhoneScript' ############ P H O N E - S C R I P T #####################################
              #tenant.call_minutes += (record_duration/60.0).ceil
              # call notice
              ClientMailer.delay(priority: 0).all_calls_received_support(call_detail.created_at, call_detail.call_from, phone_number.name, call_detail, phone_number.business.name)
              if phone_number.call_notice?
                emails = phone_number.email_ids.pluck(:emails)
                if emails.present?
                  ClientMailer.delay(priority: 0).all_calls_received(call_detail.created_at, call_detail.call_from, phone_number.name, call_detail, emails)
                  Notification.create(title: 'A call was received', notifiable_type: 'PhoneScript', notify_on: Time.now,
                                      content: "<span>A call was received for the script #{phone_number.name} from phone number #{call_detail.call_from}.</span>")
                end
                # send SMS notice
                if twilio_number.sms
                  body = "A new call received at #{timestamp} from #{call_detail.call_from} for phone script #{phone_number.name}."
                  phone_number.notify_numbers.map(&:call_number).each do |number|
                    LongTasks.send_sms_notice(twilio_number.phone_line, number, body)
                  end
                end # if sms
              end
            when 'Voicemail' ############### V O I C E M A I L ##################################
              tenant.mail_minutes += (record_duration/60.0).ceil
              #if url
              #  ClientMailer.delay.voicemail(call_detail.call_from, call_detail.created_at, url, tenant.timezone, phone_number.email_ids.pluck(:emails))
              #end
              if recording_sid
                mail_url = "http://#{tenant.subdomain}.yestrak.com/voicemail/#{recording_sid}"
                ClientMailer.delay.voicemail(call_detail.call_from, call_detail.created_at, mail_url, tenant.timezone, phone_number.email_ids.pluck(:emails))
                Notification.create(title: 'A new voicemail was added to your account', notifiable_type: 'Voicemail', notify_on: Time.now,
                                    content: "<span>A message was added to your account for the voicemail #{phone_number.name} from phone number #{call_detail.call_from}.</span>")
                # send SMS notice
                if twilio_number.sms
                  #to_sms = phone_number.business.phone_number.call_number rescue nil
                  #if to_sms
                  #  bitly =  Bitly.client
                  #  sms_url = bitly.shorten(mail_url)
                  #  body = "A new voicemail received at #{timestamp} from #{call_detail.call_from}: #{sms_url.short_url}"
                  #  LongTasks.send_sms_notice(twilio_number.phone_line, to_sms, body)
                  #end
                  sms_url = nil
                  phone_number.notify_numbers.map(&:call_number).each do |to_sms|
                    sms_url ||= Bitly.client.shorten(mail_url)
                    body = "A new voicemail received at #{timestamp} from #{call_detail.call_from}: #{sms_url.short_url}"
                    LongTasks.send_sms_notice(twilio_number.phone_line, to_sms, body)
                  end
                end # if sms
              end
            when 'PhoneMenu' ########### P H O N E - M E N U ######################################
              tenant.menu_minutes += (call_duration/60.0).ceil
          end
          tenant.save
        end # eof if phone_number
      end # eof if call_detail
    end
  end
  handle_asynchronously :update_on_call_complete

end
