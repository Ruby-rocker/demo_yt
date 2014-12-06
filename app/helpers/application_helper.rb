module ApplicationHelper

  #def notice_link
  #  {'Business' => settings_businesses_path, 'Contact' => settings_contacts_path,
  #   'Voicemail' => settings_voicemails_path, 'PhoneScriptData' => '#',
  #   'PhoneScript' => '#', 'Calendar' => current_user.is_staff? ? '#' : settings_calendars_path,
  #   'Appointment' => '#', 'PhoneMenu' => settings_phone_menus_path,
  #   'BillingInfo' => settings_billings_path, 'User' => settings_users_path,
  #   'Recording' => call_recordings_path, 'Help' => '#', 'Tenant' => settings_users_path, 'Announcement' => '#'}
  #end

  def notice_link(notification_id, notification_type, notification_title)
    case notification_type
      when "Business"
        if notification_title.include?('added') || notification_title.include?('edited')
          business = Business.unscoped.where('id = ?',notification_id)
          if business.present?
            notification_link = edit_settings_business_path(notification_id)
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "PhoneScript"
        if notification_title.include?('added') || notification_title.include?('created') || notification_title.include?('edited') || notification_title.include?('swapped') || notification_title.include?('changed')
          phone_script = PhoneScript.unscoped.where('id = ? and is_deleted = ?',notification_id,0)
          if phone_script.present?
            notification_link = edit_settings_phone_script_path(notification_id)
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "Calendar"
        if notification_title.include?('created') || notification_title.include?('edited') || notification_title.include?('imported')
          calendar = Calendar.unscoped.where('id = ?',notification_id)
          if calendar.present?
            notification_link = edit_settings_calendar_path(notification_id)
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "Appointment"
        if notification_title.include?('booked') || notification_title.include?('edited')
          appointment = Appointment.unscoped.where('id = ?',notification_id)
          if appointment.present?
            notification_link = calendars_path
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "Contact"
        if notification_title.include?('entered') || notification_title.include?('edited')
          contact = Contact.unscoped.where('id = ?',notification_id)
          if contact.present?
            notification_link = contacts_path
          else
            notification_link = false
          end
        elsif notification_title.include?('imported') || notification_title.include?('exported')
          notification_link = settings_contacts_path
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "Recording"
        if notification_title.include?('subscribed') || notification_title.include?('unsubscribed')
          notification_link = settings_call_recordings_path
        else
          notification_link = false
        end
      when "PhoneMenu"
        if notification_title.include?('created') || notification_title.include?('edited') || notification_title.include?('swapped') || notification_title.include?('changed')
          phone_menu = PhoneMenu.unscoped.where('id = ? and is_deleted = ?',notification_id,0)
          if phone_menu.present?
            notification_link = edit_settings_phone_menu_path(notification_id)
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "Voicemail"
        if notification_title.include?('created') || notification_title.include?('added') || notification_title.include?('swapped') || notification_title.include?('changed')
          voicemail = Voicemail.unscoped.where('id = ? and is_deleted = ?',notification_id,0)
          if voicemail.present?
            notification_link = edit_settings_voicemail_path(notification_id)
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted')
          notification_link = false
        end
      when "User"
        if notification_title.include?('created') || notification_title.include?('changed') || notification_title.include?('added')
          user = User.unscoped.where('id = ?',notification_id)
          if user.present?
            notification_link = settings_users_path
          else
            notification_link = false
          end
        elsif notification_title.include?('deleted') ||  notification_title.include?('Cancelled')
          notification_link = false
        end
      when "BillingInfo"
        if notification_title.include?('edited')
          notification_link = edit_settings_billing_path(notification_id)
        elsif notification_title.include?('Upgraded') ||  notification_title.include?('Downgraded')
          notification_link = settings_billings_path
        end
      when "Help"
        if notification_title.include?('Help')
          notification_link = help_index_path
        end
      else
        notification_link = root_path
    end
  end

  def img_src
    {'Business' => 'icon_business@2x.png', 'Contact' => 'icon_contact@2x.png',
     'Voicemail' => 'icon_voicemail@2x.png', 'PhoneScriptData' => 'icon_script@2x.png',
     'PhoneScript' => 'icon_script@2x.png', 'Calendar' => 'icon_calendar@2x.png',
     'Appointment' => 'icon_appointment@2x.png', 'PhoneMenu' => 'icon_menu@2x.png',
     'BillingInfo' => 'icon_billing@2x.png', 'User' => 'icon_new_user@2x.png',
     'Recording' => 'icon_recordings@2x.png', 'Help' => 'icon_appointment@2x.png',
     'Tenant' => 'icon_new_user@2x.png', 'Announcement' => 'icon_new_user@2x.png'}
  end

  def unread_notifications(notifications)
    content_tag :ul, id: 'content_1' do
      notifications[0..4].map do |notification|
        concat content_tag(:li, class: notification.is_read? ? '' : 'active', id: notification.id) {
          content_tag(:div, image_tag(img_src[notification.notifiable_type], width: '50', alt: ''), class: 'user_icon') +
          content_tag(:div, class: 'user_noti_info') {
            notification_link = notice_link(notification.notifiable_id, notification.notifiable_type,notification.title)
            if notification_link
              link_to(notification.title, notification_link) + notification.content.html_safe + "<span><i>#{notification.notify_on.strftime('%B %-d, %Y %-I:%M%P')}</i></span>".html_safe
            else
              content_tag(:div, notification.title, style: 'font:bold 12px Arial, Helvetica, sans-serif; color:#23b0d8;') + notification.content.html_safe + "<span><i>#{notification.notify_on.strftime('%B %-d, %Y %-I:%M%P')}</i></span>".html_safe
            end
          }
        }
      end if notifications.present?
      if Notification.count > 5
        concat content_tag(:li, id: 'link_see_more', class: 'see_more'){
          link_to('See More', root_path)
        }
      end
    end
  end

  def seconds_to_time(total_seconds)
    total_seconds = total_seconds.to_i
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)
    if hours.zero?
      format("%d:%02d", minutes, seconds)
    else
      format("%d:%02d:%02d", hours, minutes, seconds)
    end
  end

  # For getting contrast color 
  def getContrastYIQ(a)
    r = a[0,2].hex
    g = a[2,2].hex
    b = a[4,2].hex
    yiq = ((r*299)+(g*587)+(b*114))/1000
    return (yiq >= 128) ? 'black' : 'white'
  end
end
