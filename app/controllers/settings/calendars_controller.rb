module Settings
  class CalendarsController < ApplicationController

    include IceCube

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
    	@calendars = Calendar.all
    end

    def new
      @calendar = Calendar.new
      @business = Business.all
      @calendar.calendar_hours.build
      add_breadcrumb "Calendars", settings_calendars_path
    end

    def create
      params[:calendar][:calendar_auth_token] = SecureRandom.hex
      @calendar = Calendar.new(params[:calendar])
      if @calendar.save!
        if params[:file]
          @calendar = Calendar.last
          @calendar.import(params[:file], current_user)
          @calendar.notifications.create(title: 'A calendar was imported', notify_on: Time.now,
                                         content: "<span>An external calendar has been imported and merged with the YesTrak calendar named #{@calendar.name}.</span>" \
                                      "<span>The import was initiated by #{current_user.full_name}.</span>" \
                                      "<span>The calendar is related to the business named #{@calendar.business.name}.</span>")
        end

        # =========== M A I L E R ============
        ClientMailer.delay.calendar_created(@calendar,current_user.email)
        # =========== M A I L E R ============
        @calendar.notifications.create(title: 'A new calendar was created', notify_on: Time.now,
                             content: "<span>The calendar #{@calendar.name} was created by #{current_user.full_name}.</span>" \
                                      "<span>The calendar is related to the business named #{@calendar.business.name}. </span>")
        redirect_to settings_calendars_path, notice: "Calendar saved successfully"
      else
        render :new
      end
    end

    def edit
      @calendar = Calendar.find(params[:id])
      @business = Business.all
      @calendar_hours = @calendar.calendar_hours
      add_breadcrumb "Calendars", settings_calendars_path
    end    

    def update

      params[:calendar][:calendar_hours_attributes].each_with_index do |calendar_hour, index|
        if index != 0
          if !calendar_hour[1]["week_days"].present?
            calendar_hour[1]["week_days"] = [""]
          end
        end
      end

      if params[:cancel_sync].present?

        cal = Calendar.find(params[:id])

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
        cal.save

      end

      @calendar = Calendar.find(params[:id])
      if @calendar.update_attributes!(params[:calendar])
        if params[:file]
          @calendar.import(params[:file], current_user)
          @calendar.notifications.create(title: 'A calendar was imported', notify_on: Time.now,
                                         content: "<span>An external calendar has been imported and merged with the YesTrak calendar named #{@calendar.name}.</span>" \
                                        "<span>The import was initiated by #{current_user.full_name}.</span>" \
                                        "<span>The calendar is related to the business named #{@calendar.business.name}.</span>")
        end

        @calendar.notifications.create(title: 'A calendar was edited', notify_on: Time.now,
                                       content: "<span>The calendar #{@calendar.name} was edited by #{current_user.full_name}.</span>" \
                                      "<span>The calendar is related to the business named #{@calendar.business.name}.</span>")
        redirect_to settings_calendars_path, notice: "Calendar saved successfully"
      else
        render :edit
      end
    end

    def destroy

      # =========== M A I L E R ============
      ClientMailer.delay.calendar_deleted(Calendar.find(params[:id]),current_user.email)
      # =========== M A I L E R ============

      @calendar = Calendar.find(params[:id])
      Calendar.find(params[:id]).destroy
      @calendar.notifications.create(title: 'A calendar was deleted', notify_on: Time.now,
                                     content: "<span>The calendar #{@calendar.name} was deleted by #{current_user.full_name}.</span>" \
                                      "<span>The calendar is no longer available for appointments, past, present of future, in the system.</span>")
      redirect_to settings_calendars_path, notice: "Calendar deleted successfully"
    end

    def add_appointment_detail
    	@count = params[:count]
    end

    def check_duplicate_name
      if params[:calendar_id].present?
        cal_name = Calendar.find_by_name(params[:calendar][:name])
        cal = Calendar.find(params[:calendar_id])
        render text: (cal_name.present? ? (cal_name == cal) : true)
      else
        render text: !Calendar.find_by_name(params[:calendar][:name]).present?
      end
    end

    def remove_calendar_hour
      CalendarHour.find(params[:calendar_hour_id]).destroy
      head :ok
    end

    def ical
      headers['Content-Type'] = "text/calendar; charset=UTF-8"

      calendar_check = Calendar.find_by_calendar_auth_token(params[:auth])

      if calendar_check.present?
        send_data Calendar.to_ics(calendar_check)
      else
        #render :nothing => true
        head :ok
      end

    end
  end
end
