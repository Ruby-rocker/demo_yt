class Appointment < ActiveRecord::Base
  acts_as_tenant(:tenant)
  include IceCube
  extend CalendarsHelper

  belongs_to :tenant
  belongs_to :calendar
  belongs_to :contact
  belongs_to :user
  belongs_to :phone_script
  has_many :notifications, as: :notifiable

  attr_protected :tenant_id
  attr_accessor :recurring, :periodically, :weekly, :monthly, :ends_on, :from_ical
  after_create :create_notifications, :if => "via_xps"
  before_save :set_schedule, :unless => "from_ical"

  serialize :schedule, Hash

  index = 0
  incrementer = -> { index += 1}

  # get calendar month
  def self.set_calendar(date, year = nil, month = nil)
    date = date.beginning_of_month
    date = Date.civil(year.to_i,month.to_i) if year && month
    first_day = date.day
    last_day = date.end_of_month.day
    date_prev = date - 1
    date_next = date.next_month #date + 1.month
    prev_month = ((date_prev.day-date.wday+1)..date_prev.day).to_a
    all_days = prev_month + (first_day..last_day).to_a
    all_days = all_days.in_groups_of(7)
    j = 0
    all_days[-1] = all_days.last.map {|i| if i.nil? then j+=1 else i end }
    full_calendar = []
    temp = {}
    all_days.first.map {|i| if prev_month.include?(i) then temp.merge!(i=>date_prev.month) else temp.merge!(i=>date.month) end}
    full_calendar << temp
    all_days[1..-2].map {|a| temp = {}; a.map {|i| temp.merge!(i=>date.month)}; full_calendar << temp }
    temp = {}
    all_days.last.map {|i| if (1..7).include?(i) then temp.merge!(i=>date_next.month) else temp.merge!(i=>date.month) end}
    full_calendar << temp
    return full_calendar
  end

  def self.set_week(date=nil)
    date = date ? Date.parse(date.to_s) : Date.today
    week = date.wday
    start_day = date.prev_day(week)
    end_day = date.next_day(6-week)
    return start_day.step(end_day).to_a
  end

  def self.recurring_hash(date, calendar_id=nil)
    r_hash = {}
    repeat_apps = where(repeat: true)
    repeat_apps = repeat_apps.where(calendar_id: calendar_id) if calendar_id.present?
    repeat_apps.each do |i|
      s = Schedule.from_hash(i.schedule)
      s.occurrences_between(date - 7.days, date.end_of_month + 7.days).each do |j|
        if  r_hash[j.to_date.to_s]
          r_hash[j.to_date.to_s].merge!( i.id => {'start_time' => i.start_at, 'end_time' => i.end_at, 'name' => i.contact.try(:first_name), 'color' => i.calendar.color}  )
        else
          r_hash[j.to_date.to_s] = { i.id => {'start_time' => i.start_at, 'end_time' => i.end_at, 'name' => i.contact.try(:first_name), 'color' => i.calendar.color}  }
        end
      end
    end
    r_hash
  end

  def self.google_calendar_authentication(token,refresh_token)
    client = Google::APIClient.new
    client.authorization.client_id = "#{APP_CONFIG['google_oauth2']['client_id']}"
    client.authorization.client_secret = "#{APP_CONFIG['google_oauth2']['client_secret']}"
    client.authorization.scope = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar'
    client.authorization.access_token = token
    client.authorization.refresh_token = refresh_token

    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end

    service = client.discovered_api('calendar', 'v3')

    return service,client
  end

  def self.sync_google_calendar(token,refresh_token,t_id,cal,curr_user)

    service_client_array = google_calendar_authentication(token,refresh_token)
    service = service_client_array.first
    client = service_client_array.last

    ############## insert into Google Calendar (Yestrak to Google Calendar) ##############

    tenant = Tenant.find(t_id)
    tenant.set_as_active

    appointments = cal.appointments

    appointments.each do |appointment|
      if appointment.event_id.present?

        result = client.execute(:api_method => service.events.get,
                                :parameters => {'calendarId' => 'primary', 'eventId' => appointment.event_id})
        event = result.data

        if event.status != 'cancelled'
          if event.updated.present? && (appointment.updated_at > event.updated)

            event.summary = appointment.contact.notes.first.try(:content) if (appointment.contact.notes.present? && appointment.contact.notes.first.try(:content).present?)

            if event.start['date'].present?
              event.start.date = appointment.start_at.strftime("%Y-%m-%d")
              #event.start.date = appointment.start_at.to_date
            else
              #event.start.dateTime = appointment.start_at.strftime("%Y-%m-%dT%H:%M:%S")
              event.start.dateTime = appointment.start_at.to_time
              event.start.timeZone = "UTC" if event.start['timeZone'].present?
            end

            if event.end['date'].present?
              event.end.date = appointment.end_at.strftime("%Y-%m-%d")
              #event.end.date = appointment.end_at.to_date
            else
              #event.end.dateTime = appointment.end_at.strftime("%Y-%m-%dT%H:%M:%S")
              event.end.dateTime = appointment.end_at.to_time
              event.end.timeZone = "UTC" if event.end['timeZone'].present?
            end

            if appointment.repeat?
              rec = []
              schedule = Schedule.from_hash(appointment.schedule.to_hash).to_ical
              rec.push(schedule.split("\n")[1])
              event.recurrence = rec
            end
            result = client.execute(:api_method => service.events.update,
                                    :parameters => {'calendarId' => 'primary', 'eventId' => event.id},
                                    :body_object => event,
                                    :headers => {'Content-Type' => 'application/json'})
          end
        else
          appointment.destroy
        end
      else
        rec = []
        if appointment.repeat?
          schedule = Schedule.from_hash(appointment.schedule.to_hash).to_ical
          rec.push(schedule.split("\n")[1])
        end

        event = {
            'summary' => appointment.contact.notes.first.try(:content),
            'start' => {
                #'dateTime' => appointment.start_at.strftime("%Y-%m-%dT%H:%M:%S"),
                'dateTime' => appointment.start_at.to_time,
                'timeZone' => "UTC"
            },
            'end' => {
                #'dateTime' => appointment.end_at.strftime("%Y-%m-%dT%H:%M:%S"),
                'dateTime' => appointment.end_at.to_time,
                'timeZone' => "UTC"
            },
            'recurrence' => rec
        }

        result = client.execute(:api_method => service.events.insert,
                                :parameters => {'calendarId' => 'primary'},
                                :body => JSON.dump(event),
                                :headers => {'Content-Type' => 'application/json'})

        appointment.event_id = result.data.id
        appointment.save
      end

    end

    ############## insert into YesTrak (Google Calendar to Yestrak) ##############
    sleep 5
    @result = client.execute(:api_method => service.events.list,
                             :parameters => {'calendarId' => 'primary'},
                             :headers => {'Content-Type' => 'application/json'})

    @result.data.items.each do |item|
      start_time = item.start.date || item.start.dateTime
      end_time = item.end.date || item.end.dateTime
      appointment = cal.appointments.find_by_event_id(item.id)

      if cal.valid_time?(start_time.to_time.in_time_zone(cal.timezone), end_time.to_time.in_time_zone(cal.timezone), appointment)
        if appointment.present?
          if item.updated.present? && (item.updated > appointment.updated_at)
            appointment.start_at = start_time
            appointment.end_at = end_time
            existing_note = Note.find_by_content_and_contact_id(item.summary, appointment.contact_id)
            Note.create(:content => item.summary, :contact_id => appointment.contact_id, :user_id => curr_user.id) if existing_note.blank?
            if item.recurrence.blank?
              appointment.repeat = 0
            else
              google_rec = item.recurrence[0].sub('RRULE:','')
              rule = Rule.from_ical(google_rec)
              recur = Schedule.new(appointment.start_at, :end_time => appointment.end_at)
              recur.add_recurrence_rule rule
              appointment.schedule = recur.to_hash
              appointment.repeat = 1
              appointment.from_ical = true
            end
            appointment.save
          end
        else
          contact = Contact.joins(:email_ids).where("email_ids.emails" => item.creator.email).first
          if !contact.present?
            contact = Contact.new
            contact.full_name = item.creator.displayName
            contact.email_ids.new(emails: item.creator.email)
            contact.phone_numbers.new(name: 'Home', area_code: '000', phone1: '000', phone2: '0000')
            contact.address = Address.new(timezone: cal.timezone)
            contact.save
          end
          appointment = contact.appointments.new
          appointment.start_at = start_time
          appointment.end_at = end_time
          contact.notes.create(:content => item.summary, :user_id => curr_user.id)
          appointment.calendar_id = cal.id
          appointment.event_id = item.id
          if item.recurrence.blank?
            appointment.repeat = 0
          else
            google_rec = item.recurrence[0].sub('RRULE:','')

            rule = Rule.from_ical(google_rec)
            recur = Schedule.new(appointment.start_at, :end_time => appointment.end_at)
            recur.add_recurrence_rule rule

            appointment.schedule = recur.to_hash
            appointment.repeat = 1
            appointment.from_ical = true
          end
          appointment.save
        end
      end
    end
  end

  def set_schedule
    if repeat?
      recur = Schedule.new(self.start_at, :end_time => self.end_at)

      if ends_on.present?
        ends_on_date = ends_on.split('/')
        ends_time = (ends_on_date[1] + '/' + ends_on_date[0] + '/' + ends_on_date[2] + ' ' + self.end_at.strftime('%H:%M:%S'))#.to_time
        ends_time = Time.zone.parse(ends_time)
      end

      self.repeat = 1

      if recurring == 'never'
        self.repeat = 0
      elsif recurring == 'daily'
        if ends_time.present?
          recur.add_recurrence_rule Rule.daily.until(ends_time)
        else
          recur.add_recurrence_rule Rule.daily
        end
      elsif recurring == 'periodically'
        if ends_time.present?
          recur.add_recurrence_rule Rule.daily(periodically.to_i).until(ends_time)
        else
          recur.add_recurrence_rule Rule.daily(periodically.to_i)
        end
      elsif recurring == 'weekly'
        if ends_time.present?
          recur.add_recurrence_rule Rule.weekly.day(weekly.to_i).until(ends_time)
        else
          recur.add_recurrence_rule Rule.weekly.day(weekly.to_i)
        end
      elsif recurring == 'monthly'
        if ends_time.present?
          recur.add_recurrence_rule Rule.monthly.day_of_month(monthly.to_i).until(ends_time)
        else
          recur.add_recurrence_rule Rule.monthly.day_of_month(monthly.to_i)
        end
      elsif recurring == 'yearly'
        if ends_time.present?
          recur.add_recurrence_rule Rule.yearly.until(ends_time)
        else
          recur.add_recurrence_rule Rule.yearly
        end
      end
      self.schedule = recur.to_hash
    else
      self.schedule = nil
    end
  end

  private ########################

  # when call center agent books an appointment
  def create_notifications
    if phone_script && phone_script.action_notice?
      emails = phone_script.email_ids.pluck(:emails)
      if emails.present?
        ClientMailer.delay.appointment_set(id, emails)
      end
      # send SMS notice
      twilio_number = phone_script.twilio_number
      if twilio_number.sms
        date_time = "#{start_at.in_time_zone(calendar.timezone).strftime('%b %d %Y, %I:%M%p') + end_at.in_time_zone(calendar.timezone).strftime(' - %I:%M%p')}"
        body = "a new appointment has been set for phone script #{phone_script.name} on #{calendar.name}. " \
                "Date/Time: #{date_time}. " \
                "Contact name: #{contact.full_name}."
        phone_script.notify_numbers.map(&:call_number).each do |number|
          LongTasks.send_sms_notice(twilio_number.phone_line, number, body)
        end
      end # if sms
    end
  end

end
