class CalendarsController < ApplicationController
	#load_and_authorize_resource

  # keep appointment related code in AppointmentsController
  # def index
  #   @calendar_month = CalendarView.set_month(params[:year], params[:month])
  # end

  # def weekly
  #   @calendar_week = CalendarView.set_week(params[:date])
  # end

  # def daily
  #   @calendar_day = params[:date] ? Time.zone.parse(params[:date]) : Time.zone.today
  # end

  include IceCube

  def index
    Time.zone = current_tenant.timezone
    @calendar_id = params[:calendar_id] || []

    if params[:appointment_search_date].present?
      search_date = params[:appointment_search_date].split('/')
      s_date = (search_date[1] + '/' + search_date[0] + '/' + search_date[2]).to_date if search_date.length == 3
    end

    now =  s_date || (Time.zone || Time).now
    month = (params[:month] || now.month).to_i
    year = (params[:year] || now.year).to_i
    @date = Date.civil(year,month)
    @calendar = Appointment.set_calendar(@date)
    @r_hash = Appointment.recurring_hash(@date, params[:calendar_id])
    @calendars = Calendar.all

    if @calendar_id.present?
      @cal_name = Calendar.find(@calendar_id).map{|calendar| calendar.name}.join(", ")
    else
      @cal_name = "All"
    end

    #@synced_cal =  Calendar.find(params[:calendar_id]) if params[:calendar_id].present?
  end

  def google_sync
    arr_response = params[:state].split(',')
    if arr_response[0].present? && arr_response[0] != '0'
      cal = Calendar.find(arr_response[0])
    else
      cal = Calendar.first
    end 
    queue = 'sync_' + cal.tenant_id.to_s + '_' + cal.id.to_s
    queue_query = Delayed::Job.where('queue = ?',queue)

    if queue_query.present?
      flash[:alert] = "Google calendar is syncing. Please wait..."
    else
      if cal.google_authentication_token.present?
        @token = cal.google_authentication_token
        @refresh_token = cal.google_authentication_refresh_token
      else
        @auth = request.env["omniauth.auth"]
        @token = @auth["credentials"]["token"]
        @google_email = @auth["info"]["email"]
        @google_name = @auth["info"]["name"]
        calendar = Calendar.where('google_authentication_email LIKE ?',@google_email).first
        if calendar.present?
          @refresh_token = calendar.google_authentication_refresh_token
        else
          @refresh_token = @auth["credentials"]["refresh_token"]
        end

        cal.google_authentication_token = @token
        cal.google_authentication_refresh_token = @refresh_token
        cal.google_authentication_email = @google_email
        cal.google_authentication_name = @google_name
        cal.save!
      end

      Appointment.delay(:queue => queue).sync_google_calendar(@token,@refresh_token,cal.tenant_id,cal,User.find(arr_response[1]))

      flash[:notice] = "Google calendar sync is started. Within a few minutes, it will be synced."

      # =========== M A I L E R ============
      ClientMailer.delay.google_sync_notification(cal)
      # =========== M A I L E R ============

      cal.notifications.create(title: 'A calendar sync was created', notify_on: Time.now,
                                     content: "<span>The YesTrak calendar #{cal.name} was synced with the Google Calendar #{cal.google_authentication_name} by #{current_user.full_name}.</span>" \
                                      "<span>The calendar is related to the business named #{cal.business.name}.</span>")
    end

    redirected_path = "http://" << cal.tenant.subdomain << "." << (Rails.env == "development" ? LOCAL_HOST : LIVE_HOST) <<"/calendar"
    redirect_to redirected_path
  end

  def cancel_google_sync

    if params[:state].present? && params[:state] != '0'
      cal = Calendar.find(params[:state])
    else
      cal = Calendar.first
    end

    queue = 'sync_' + current_user.tenant_id.to_s + '_' + cal.id.to_s
    queue_query = Delayed::Job.where('queue = ?',queue)

    queue_query[0].destroy if queue_query.present?

    # =========== M A I L E R ============
    ClientMailer.delay.google_sync_notification_cancel(cal, cal.google_authentication_email, cal.name, cal.google_authentication_name, cal.tenant.owner.full_name)
    # =========== M A I L E R ============

    cal.notifications.create(title: 'A calendar sync was deleted', notify_on: Time.now,
                                   content: "<span>The sync between the YesTrak calendar #{cal.name} and the Google Calendar #{cal.google_authentication_name} has been deleted by #{current_user.full_name}.</span>" \
                                      "<span>There will be no automatic synchronizations between these two calendars any more.</span>")

    system "curl 'https://accounts.google.com/o/oauth2/revoke?token=#{cal.google_authentication_token}'"

    cal.google_authentication_token = nil
    cal.google_authentication_refresh_token = nil
    cal.google_authentication_email = nil
    cal.google_authentication_name = nil
    cal.save!

    flash[:notice] = "Google calendar sync is canceled."
    redirect_to calendars_path
  end

  def weekly
    Time.zone = current_tenant.timezone
    @calendar_id = params[:calendar_id] || []

    if params[:appointment_search_date].present?
      search_date = params[:appointment_search_date].split('/')
      s_date = (search_date[1] + '/' + search_date[0] + '/' + search_date[2]).to_date
      params[:date] = s_date.to_s
    end
    now =  s_date || (Time.zone || Time).now
    if params[:date].present?
      arr_date = params[:date].split("-")
      month = (arr_date[1] || now.month).to_i
      year = (arr_date[0] || now.year).to_i
    else
      month = Time.new.month
      year = Time.new.year
    end
    @date = Date.civil(year,month)
    @r_hash = Appointment.recurring_hash(@date, params[:calendar_id])
    @week = Appointment.set_week(params[:date])
    @calendars = Calendar.all

    if @calendar_id.present?
      @cal_name = Calendar.find(@calendar_id).map{|calendar| calendar.name}.join(", ")
    else
      @cal_name = "All"
    end

    #@synced_cal =  Calendar.find(params[:calendar_id]) if params[:calendar_id].present?
  end

  def daily
    Time.zone = current_tenant.timezone
    @calendar_id = params[:calendar_id] || []

    if params[:appointment_search_date].present?
      search_date = params[:appointment_search_date].split('/')
      s_date = (search_date[1] + '/' + search_date[0] + '/' + search_date[2]).to_date
      params[:date] = s_date.to_s
    end

    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @calendars = Calendar.all
    @day = @date.strftime('%-d')
    @month = @date.strftime('%-m')
    @year = @date.strftime('%Y')
    @r_hash = Appointment.recurring_hash(@date, params[:calendar_id])

    if @calendar_id.present?
      @cal_name = Calendar.find(@calendar_id).map{|calendar| calendar.name.upcase}.join(", ")
      # @synced_cal = Calendar.find(params[:calendar_id])
    else
      @cal_name = "All"
    end

  end

  def appoint_view
    if params[:view_type] == "Month"
      redirect_to appointment_view_month_calendars_path(view_type: params[:view_type],calendar_id: params[:list_view_calendar_id])
    else
      redirect_to appointment_view_week_calendars_path(view_type: params[:view_type],calendar_id: params[:list_view_calendar_id])
    end
  end

  def appointment_view_month
    if params[:appointment_search_date].present?
      search_date = params[:appointment_search_date].split('/')
      s_date = (search_date[1] + '/' + search_date[0] + '/' + search_date[2]).to_date
    end
    now =  s_date || (Time.zone || Time).now
    month = (params[:month] || now.month).to_i
    year = (params[:year] || now.year).to_i
    @date = Date.civil(year,month)
    @calendar = Appointment.set_calendar(@date)
    @calendars = Calendar.all

    if params[:calendar_id].present?
      @synced_cal = Calendar.find(params[:calendar_id])
      @cal_name = Calendar.find(params[:calendar_id]).name
    else
      @synced_cal = Calendar.first
      params[:calendar_id] = @synced_cal.id
      @cal_name = @synced_cal.name
    end
  end

  def appointment_view_week
    if params[:appointment_search_date].present?
      search_date = params[:appointment_search_date].split('/')
      s_date = (search_date[1] + '/' + search_date[0] + '/' + search_date[2]).to_date
      params[:date] = s_date.to_s
    end
    now =  s_date || (Time.zone || Time).now
    if params[:date].present?
      arr_date = params[:date].split("-")
      month = (arr_date[1] || now.month).to_i
      year = (arr_date[0] || now.year).to_i
    else
      month = Time.new.month
      year = Time.new.year
    end
    @date = Date.civil(year,month)
    @week = Appointment.set_week(params[:date])
    @calendars = Calendar.all
    @time_inter = []
    @blocked = []
    @week.each do |day|
      if params[:calendar_id].present?
        @calendar = Calendar.find(params[:calendar_id])
        @time_array = @calendar.time_interval_array(day.strftime("%Y-%d-%m"))
      else
        @calendar = Calendar.first
        @time_array = @calendar.time_interval_array(day.strftime("%Y-%d-%m"))
        params[:calendar_id] = @calendar.id
      end
      @working_hour = @calendar.calendar_hours.find_by_hours_type("hours")
      @appt_window = @calendar.calendar_hours.where("hours_type = ?", "windows")
      @time_inter << @time_array[0]
      @blocked << Hash[*@time_array[1].flatten]
    end

    if params[:calendar_id].present?
      @synced_cal = Calendar.find(params[:calendar_id])
      @cal_name = Calendar.find(params[:calendar_id]).name
    else
      @synced_cal = Calendar.first
      @cal_name = @synced_cal.name
    end
  end

  def appointment_day
    params[:date] = Date.parse(params[:date]).strftime("%Y-%d-%m")
    if params[:calendar_id].present?
      @calendar = Calendar.find(params[:calendar_id])
      @time_array = @calendar.time_interval_array(params[:date])
    else
      @calendar = Calendar.first
      @time_array = @calendar.time_interval_array(params[:date])
      params[:calendar_id] = @calendar.id
    end
    @working_hour = @calendar.calendar_hours.find_by_hours_type("hours")
    @appt_window = @calendar.calendar_hours.where("hours_type = ?", "windows")
    @time_inter = @time_array[0]
    @blocked_hash = Hash[*@time_array[1].flatten]
    @index_limit = (@time_array.length.to_f/3).ceil
  end

  def block_timing_modification
    calendar = Calendar.find(params[:calendar_id].to_i)
    blocked_timing = calendar.blocked_timings.find_by_appt_time_and_appt_date_and_status(params[:appt_time], params[:appt_date], [0, 1])
    blocked_timing.present? ? blocked_timing.update_block(params) : calendar.create_blocked_timing(params)
    head :ok
  end

  def list_calendars_appointments
    id_list = params[:calendars].keys
    flags = params[:calendars].values.map{|v| v.values}.flatten
    id_array = []
    id_list.each_with_index do |id, index|
      (id_array << id) if flags[index] != "0"
    end
    if params[:action_type] == "daily"
      redirect_to daily_path(params[:appointment_date], calendar_id: id_array)
    elsif params[:action_type] == "weekly"
      redirect_to weekly_path(params[:appointment_date], calendar_id: id_array)
    else
      redirect_to calendars_path("calendar_id" => id_array)
    end
  end
end