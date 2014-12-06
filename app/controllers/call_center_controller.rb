class CallCenterController < ApplicationController
  before_filter :logged_in, :except => [:index, :appointment_day]

  def index
    if params[:auth].present? && PhoneScript.find_by_script_auth_token(params[:auth]).present?
      now =  (Time.zone || Time).now
      month = (params[:month] || now.month).to_i
      year = (params[:year] || now.year).to_i
      @date = Date.civil(year,month)
      @calendar = Appointment.set_calendar(@date)
      @calendars = Calendar.all

      params[:calendar_id] = PhoneScript.find_by_script_auth_token(params[:auth]).calendar_id

      render layout: "call_center"
    else
      flash[:notice] = "Call center authentication failed."
      redirect_to root_path
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
end
