module CallRecordingsHelper
	def call_recording_records(call_recordings)
  	content_tag :section, class: 'recordingsbodytable' do
      call_recordings.present? ? call_recording_inner_records(call_recordings) : call_recordings_no_records
    end
	end

	def call_recording_inner_records(call_recordings)
    call_recordings.map do |call_recording|
      concat content_tag(:section, class: 'table_row') {
        content_tag(:div, class: 'threeColum') {
          content_tag(:div, (link_to image_tag("btn_play@2x.png", :width=>"27"), "#", onclick: "show_audio('#{call_recording.id}');"), class: 'play click', id: "div_show_audio_#{call_recording.id}") + 
          content_tag(:div, (call_recording.call_detail.call_from), class: 'caller') +
          content_tag(:div, (call_recording.date_created.strftime('%b. %d, %Y %I:%M%P')), class: 'date_time') + 
          content_tag(:div, class: 'audio_player_wrapper expand', id: "audio_div_#{call_recording.id}", style: 'display:none;') {
            content_tag(:div, class: 'audio_player') {
              content_tag(:audio, (), id: "audio_player_#{call_recording.id}", controls: "control", preload: "none", src: "#{call_recording.url}", type: "audio/mp3")
              } +
            content_tag(:div, (link_to 'Download Recording', download_recording_path(call_recording.id), class: 'button grey', id: 'download_call_recording'), class: 'audio_download')
          }
        } + 
        content_tag(:div, ((number_with_precision(seconds_to_time(call_recording.duration), precision: 2) rescue nil)), class: 'lenthcall') + 
        content_tag(:div, (Recording.phone_script_name(call_recording.id)), class: 'phoneScriptCall')
      }
    end
  end

  def call_recordings_no_records
    concat content_tag(:section, class: 'table_row') {
      content_tag(:div, class: 'threeColum') {
        content_tag(:div, class: 'no_data') {
          content_tag(:div, 'No Records Found')
        }
      }
    }
  end

  def play_link(call)
    link_to '', 'javascript:void(0);', class: 'play',
      :'data-unread' => call.is_read ? nil : "#{call.id}",
      :'data-id' => call.id,
      id: "play_record_#{call.id}"
  end
end
