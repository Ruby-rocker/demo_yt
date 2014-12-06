class AppointmentsController < ApplicationController
  include CalendarsHelper

  before_filter :logged_in, :if => "chk_call_center_request", :except => [:new, :create]

  def chk_call_center_request
    if (params[:from].present? && params[:from] == "call_center") && (params[:controller] == "call_center" && params[:action] == "appointment_day")
      return true
    else
      return false
    end
  end

  def new
    @appointment = Appointment.new
    @contact = Contact.new
    @contact.build_address
    @contact.phone_numbers.build
    @contact.email_ids.build
    @del_path = ""
    date_params = (params[:year] + '/' + params[:month] + '/' + params[:day])
    appointment_date = date_params.to_date.strftime('%a %m/%d/%Y')
    appointment_time = params[:time]
    type = params[:type]
    render partial: 'form', locals: {appointment: @appointment, appointment_date: appointment_date, appointment_time_start: "", appointment_time_end: "", appointment_time: appointment_time, type: type}
  end

  def edit
    @appointment = Appointment.find(params[:id])
    @contact = @appointment.contact
    @contact.email_ids.present? || @contact.email_ids.build
    @phone_numbers = @contact.phone_numbers
    @email_ids = @contact.email_ids
    @all_notes = @contact.notes
    @notes = (@contact.notes).order("id").limit(2)
    @del_path = appointment_path(@appointment)

    appointment_date = @appointment.start_at.in_time_zone(@appointment.calendar.timezone.to_s).strftime('%a %m/%d/%Y')

    appointment_time_start = @appointment.start_at.in_time_zone(@appointment.calendar.timezone.to_s).strftime('%-l:%M%P')
    appointment_time_end = @appointment.end_at.in_time_zone(@appointment.calendar.timezone.to_s).strftime('%-l:%M%P')

    appointment_time = params[:time]
    type = params[:type]

    render partial: 'form', locals: {appointment_date: appointment_date, appointment_time_start: appointment_time_start, appointment_time_end: appointment_time_end, appointment_time: appointment_time, type: type}
  end

  def create
    cal_timezone = Calendar.find(params[:appointment][:calendar_id]).timezone
    params[:contact][:address_attributes][:timezone] = cal_timezone
    id = Contact.is_existing_contact(params[:contact])
    if id.present?
      @contact = Contact.find_by_id(id)
      @contact.update_attributes!(params[:contact])
    else
      @contact = Contact.new(params[:contact])
      @contact.save!
    end
    
    if params[:content].present?
      if params[:from_call_center].present? && params[:from_call_center] == "call_center"
        note = Note.new(:content => params[:content], :contact_id => @contact.id, :user_id => nil )
      else
        note = Note.new(:content => params[:content], :contact_id => @contact.id, :user_id => current_user.id )
      end
      note.save!
    end

    params[:appointment][:contact_id] = @contact.id
    Time.zone = cal_timezone
    @appointment = Appointment.new(params[:appointment])

    @appointment.repeat = params[:appointment][:recurring] == "never" ? 0 : 1

    from_day_date = params[:from_date].split(' ')
    from_day = from_day_date[0]
    from_date = from_day_date[1].split('/')
    params[:from_date] = from_day + ' ' + from_date[1] + '/' + from_date[0] + '/' + from_date[2]

    @appointment.start_at = "#{params[:from_date]} #{params[:from_time]}"
    @appointment.end_at = "#{params[:from_date]} #{params[:to_time]}"

    if params[:from_call_center].present? && params[:from_call_center] == "call_center"
      @appointment.via_xps = 1
      @appointment.phone_script_id = PhoneScript.find_by_script_auth_token(params[:call_center_auth]).id
    end

    @appointment.save

    Time.zone = current_tenant.timezone

    @login_user = @appointment.via_xps ? "CALL CENTER" : current_user.full_name

    @appointment.notifications.create(title: 'Success! We booked an appointment.', notify_on: Time.now,
                                      content: "<span>An appointment for #{@appointment.contact.full_name} was added to the system by #{@login_user}.</span>")

    if params[:from_call_center].present? && params[:from_call_center] == "call_center"
      render text: '<script type="text/javascript"> window.close(); window.opener.location.reload(); </script>'
    else
      redirect_to request.env["HTTP_REFERER"]
    end

  end

  def update
    cal_timezone = Calendar.find(params[:appointment][:calendar_id]).timezone
    @appointment = Appointment.find(params[:appointment][:id])

    id = Contact.is_existing_contact(params[:contact])
    params[:contact][:address_attributes][:timezone] = cal_timezone
    if id.present?
      params[:contact] = params[:contact].except(:id)
      params[:contact][:address_attributes] = params[:contact][:address_attributes].except(:id)
      params[:contact][:phone_numbers_attributes] = params[:contact][:phone_numbers_attributes].map{|m,n| n.except(:id)}
      params[:contact][:email_ids_attributes] = params[:contact][:email_ids_attributes].map{|m,n| n.except(:id)} if params[:contact][:email_ids_attributes].present?

      @contact = Contact.find_by_id(id)
      @contact.update_attributes(params[:contact])
      # Destroy deleted phone numbers
      params[:contact][:phone_numbers_attributes].map { |k, v| PhoneNumber.find(v[:id]).destroy if v && v[:name].nil? }
      params[:contact][:email_ids_attributes].map { |k, v| EmailId.find(v[:id]).destroy if v && v[:emails].nil? }
    else
      params[:contact] = params[:contact].except(:id)
      params[:contact][:address_attributes] = params[:contact][:address_attributes].except(:id)
      params[:contact][:phone_numbers_attributes] = params[:contact][:phone_numbers_attributes].map{|m,n| n.except(:id)}
      params[:contact][:email_ids_attributes] = params[:contact][:email_ids_attributes].map{|m,n| n.except(:id)} if params[:contact][:email_ids_attributes].present?
      @contact = Contact.new(params[:contact])
      @contact.save
    end

    if params[:content].present?
      note = Note.new(:content => params[:content], :contact_id => @contact.id, :user_id => current_user.id )
      note.save!
    end

    params[:appointment][:contact_id] = @contact.id
    Time.zone = cal_timezone
    @appointment.repeat = params[:appointment][:recurring] == "never" ? 0 : 1

    from_day_date = params[:from_date].split(' ')
    from_day = from_day_date[0]
    from_date = from_day_date[1].split('/')
    params[:from_date] = from_day + ' ' + from_date[1] + '/' + from_date[0] + '/' + from_date[2]

    @appointment.start_at = "#{params[:from_date]} #{params[:from_time]}"
    @appointment.end_at = "#{params[:from_date]} #{params[:to_time]}"
    @appointment.update_attributes(params[:appointment])

    Time.zone = current_tenant.timezone

    @appointment.notifications.create(title: 'An appointment was edited', notify_on: Time.now,
      content: "<span>The appointment for #{@appointment.contact.full_name} was edited in the system by #{current_user.full_name}.</span>")

    redirect_to request.env["HTTP_REFERER"]
  end

  def destroy

    @appointment = Appointment.find(params[:id])
    @appointment_notification = Appointment.find(params[:id])

    cal = @appointment.calendar

    if cal.google_authentication_token.present?
      @token = cal.google_authentication_token
      @refresh_token = cal.google_authentication_refresh_token
    else
      @auth = request.env["omniauth.auth"]
      if @auth.present?
        @token = @auth["credentials"]["token"]
        @refresh_token = @auth["credentials"]["refresh_token"]
      end

      cal.google_authentication_token = @token
      cal.google_authentication_refresh_token = @refresh_token
      cal.save
    end

    if @token && @refresh_token
      service_client_array = Appointment.google_calendar_authentication(@token,@refresh_token)
      service = service_client_array.first
      client = service_client_array.last

      if cal.google_authentication_token.present? && @appointment.event_id.present?
        result = client.execute(:api_method => service.events.delete,
                                :parameters => {'calendarId' => 'primary', 'eventId' => @appointment.event_id})
      end
    end

    @appointment.destroy

    @appointment_notification.notifications.create(title: 'An appointment was deleted', notify_on: Time.now,
                                      content: "<span>The appointment for contact #{@appointment_notification.contact.full_name} was deleted from the system by #{current_user.full_name}.</span>")

    redirect_to request.env["HTTP_REFERER"]
  end

  def is_valid_time
    calendar = Calendar.find(params[:calendar_id])
    date_from = params[:from_date].split(" ")[1].split("/")
    date_from = date_from.replace( [date_from[1], date_from[0], date_from[2]] ).join("/")
    appointment = (params[:id].present? ? Appointment.find(params[:id]) : "")
    zone = Time.zone
    Time.zone = calendar.timezone
    start_at = Time.zone.parse("#{date_from} #{params[:from_time]}")
    end_at = Time.zone.parse("#{date_from} #{params[:to_time]}") - 1.minutes
    Time.zone = zone
    respond_to do |format|
      format.json { render :json => calendar.valid_time?(start_at, end_at, appointment) }
    end
  end
end
