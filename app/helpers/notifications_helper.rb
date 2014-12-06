module NotificationsHelper

  #IMG_SRC = {'Business' => 'icon_business@2x.png', 'Contact' => 'icon_contact@2x.png',
  #           'Voicemail' => 'icon_voicemail@2x.png', 'PhoneScriptData' => 'icon_script@2x.png',
  #           'PhoneScript' => 'icon_script@2x.png', 'Calendar' => 'icon_calendar@2x.png',
  #           'Appointment' => 'icon_appointment@2x.png', 'PhoneMenu' => 'icon_menu@2x.png',
  #           'BillingInfo' => 'icon_billing@2x.png', 'User' => 'icon_new_user@2x.png',
  #           'Recording' => 'icon_recordings@2x.png'}


  def notification_list(notifications)
    content_tag :ul, class: 'list_of' do
      notification_li_tags(notifications)
    end
  end

  def notification_li_tags(notifications)
    if notifications.present?
      notifications.map do |note|
        concat content_tag(:li) {
          content_tag(:div, image_tag(img_src[note.notifiable_type], width: '66', alt: ''), class: 'icons') +
          content_tag(:div, "#{note.notify_on.strftime('%B %-d, %Y')}<br>#{note.notify_on.strftime('%-I:%M%P')}".html_safe, class: 'list_of_info_date_time') +
          content_tag(:div, class: 'list_of_info') {
            notification_link = notice_link(note.notifiable_id, note.notifiable_type,note.title)
            if notification_link
              link_to(note.title, notification_link) + note.content.html_safe
            else
              content_tag(:span, note.title, style: 'color: #23B0D8; font-size: 14px; font-weight: bold;') + note.content.html_safe
            end
          }
        }
      end
    else
      concat content_tag(:li) {
        content_tag(:div, "No data Found", class: 'no_data')
      }
    end
  end

end
