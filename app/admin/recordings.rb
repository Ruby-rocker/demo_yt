ActiveAdmin.register Recording do
  menu :priority => 8

  actions :all, :except => [:destroy, :new, :edit]

  config.sort_order = 'created_at_desc'

  filter :duration
  filter :is_heard

  index do
    column "Caller" do |object|
      Recording.caller(object.id) rescue nil
    end

    column "Date/Time" do |object|
      object.date_created.strftime('%b. %m, %Y %I:%M%P') rescue nil
    end

    column "Length" do |object|
      number_with_precision(object.duration, precision: 2) rescue nil
    end

    column "Phone Script" do |object|
      Recording.phone_script_name(object.id) rescue nil
    end
    default_actions
  end

  show :title => 'Show Recording' do |sr|
    attributes_table do
      row :id
      row :recording_sid
      row "Caller" do
        Recording.caller(sr.id) rescue nil
      end
      row "Date/Time" do
        sr.date_created.strftime('%b. %m, %Y %I:%M%P') rescue nil
      end

      row "Length" do
        number_with_precision(sr.duration, precision: 2) rescue nil
      end

      row "Phone Script" do
        Recording.phone_script_name(sr.id) rescue nil
      end

      row "Play/Download" do
        if sr.url
          div :class => "audio_player_wrapper expand", :id => "audio_div_#{sr.id}" do
            audio :class => "audio_player", :id => "audio_player_#{sr.id}", :controls => "control", :src => "#{sr.url}", :type => "audio/mp3" do
            end
            div :class => 'audio_download' do
              link_to 'Download Recording', admin_download_recording_path(sr.id), :class => 'button grey', :id => 'download_call_recording'
            end
          end
        end
      end
    end
  end

  controller do
    def admin_download
      if params[:id]
        recording = Recording.find(params[:id])
        recording.store_recording unless File.exists?("storage/call_recordings/#{recording.recording_sid}.mp3")
        if File.exists?("storage/call_recordings/#{recording.recording_sid}.mp3")
          send_file Rails.root.join("storage/call_recordings/#{recording.recording_sid}.mp3"), :type=>"audio/mp3"
        else
          render nothing: true
        end
      else
        redirect_to root_path, alert: 'No recording exists for this call.'
      end
    end

  end
end
