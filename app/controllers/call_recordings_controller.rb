class CallRecordingsController < ApplicationController
	#load_and_authorize_resource
  #before_filter :check_user, :only => [:index]
  before_filter :check_subscribed, :only => [:index]
  skip_before_filter :set_defaults, only: [:download]
  skip_before_filter :set_defaults, :logged_in, only: [:voicemail_test, :voicemail]

  def index
		# @date_range = (params[:call_records_search][:date] rescue nil)
    
		@call_records_search = (params[:call_records_search][:date] rescue nil)
    @date_from = (params[:call_records_search][:date_from] rescue nil)
    @date_to = (params[:call_records_search][:date_to] rescue nil)

		session[:limit] = params[:limit] || session[:limit]
		@recordings = Recording.phone_script_records
		@recordings = @recordings.filter(params[:call_records_search], "", "call_recordings") if (params[:call_records_search] && (params[:call_records_search][:date] || params[:call_records_search][:date_from]))
    @displaying_range = Recording.displaying_range

		@recordings = @recordings.filter_by_phone_script(params[:call_records_search]) if (params[:call_records_search] && params[:call_records_search][:phone_script] && params[:call_records_search][:phone_script] != "")

		@total_record = @recordings.size
		@recordings = @recordings.page(params[:page]).per(session[:limit])
		@record = {name:'recordings',path:call_recordings_path,remote:true}
		respond_to do |format|
      format.html
      format.js { }
    end
	end

	def daterange_selector
    render partial: 'daterange_selector'
  end

  def check_subscribed
    add_on = current_tenant.record_call_logs.last_log.first
    if (add_on.blank? || (add_on.present? && add_on.deleted?)) && current_user.is_super_user?
      redirect_to settings_call_recordings_path
    elsif (add_on.blank? || (add_on.present? && add_on.deleted?)) && !current_user.is_super_user?
      redirect_to root_url, :notice => "Please contact your owner to subscribe for this service"
    end
  end

  #def check_user
  #	@add_on = AddOn.active_call_recording
  #  if @add_on.blank? && current_user.is_super_user?
  #    redirect_to settings_call_recordings_path
  #  elsif @add_on.blank? && !current_user.is_super_user?
  #    redirect_to root_url, :notice => "Please contact your owner to subscribe for this service"
  #  end
  #end

  def download
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

  def voicemail
    logger.info("====HEADER// #{request.headers['X-Sendfile']} -- #{request.headers['x_sendfile']}//=======")
    record = Recording.find_by_recording_sid(params[:sid])
    session[:sid] = nil if session[:sid]
    if record
      record.store_recording unless File.exists?("storage/call_recordings/#{params[:sid]}.mp3")

      send_file("#{Rails.root}/storage/call_recordings/#{params[:sid]}.mp3",
                :filename => "#{params[:sid]}.mp3",
                #:type => "audio/mp3", #for example if pdf
                #type: 'audio/x-wav',
                type: "audio/mpeg",
                #type: "application/force-download",
                #:x_sendfile=>true,
                #stream: true,
                :disposition => 'inline')#send inline instead of attachment
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end
  end

  def voicemail_test    #http://rack.rubyforge.org/doc/Rack/Sendfile.html
    logger.info("====HEADER// #{request.headers['X-Sendfile']} -- #{request.headers['x_sendfile']}//=======")
    record = Recording.find_by_recording_sid(params[:sid])
    session[:sid] = nil if session[:sid]
    if record
      record.store_recording unless File.exists?("storage/call_recordings/#{params[:sid]}.mp3")

      send_file("#{Rails.root}/storage/call_recordings/#{params[:sid]}.mp3",
                :filename => "#{params[:sid]}.mp3",
                #:type => "audio/mp3", #for example if pdf
                #type: 'audio/x-wav',
                type: "audio/mpeg",
                #type: "application/force-download",
                #:x_sendfile=>true,
                #stream: true,
                :disposition => 'inline')#send inline instead of attachment
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end
  end #http://thr3ads.net/similar?t=2521812-Apache-configuration-for-using-plugin-Xsendfile

end
