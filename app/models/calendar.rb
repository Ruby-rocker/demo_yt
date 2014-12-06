class Calendar < ActiveRecord::Base
  acts_as_tenant(:tenant)
  include IceCube
  include CalendarsHelper
  APT_LENGTH = {'15' => '15 minutes', '30' => '30 minutes', '45' => '45 minutes',
                '60' => '60 minutes', '90' => '90 minutes', '120' => '120 minutes'}

  attr_protected :tenant_id
  belongs_to :tenant
  belongs_to :business
  has_many   :calendar_hours, dependent: :destroy
  has_many   :appointments, dependent: :destroy
  has_many   :blocked_timings, dependent: :destroy
  has_many  :phone_scripts
  has_many :notifications, as: :notifiable
  attr_accessible :apt_length, :color, :name, :timezone, :business_id, :calendar_hours_attributes, :calendar_auth_token

  validates :apt_length, inclusion: { in: %w(15 30 45 60 90 120) }
  validates :name, presence: true

  accepts_nested_attributes_for :calendar_hours

  def import(file, curr_usr)
    cal_file = File.open(file.path)
    cals = Icalendar.parse(cal_file)

    cals.each do |cal|
      (cal.events).each do |event|
        if self.valid_time?(event.dtstart, event.dtend, "")
          appointment = self.appointments.new

          contact = Contact.joins(:email_ids).where("email_ids.emails" => curr_usr.email).first
          if contact.present?
            appointment.contact_id = contact.id
          else
            contact = Contact.new
            contact.first_name = curr_usr.first_name
            contact.last_name = curr_usr.last_name
            contact.email_ids.new(emails: curr_usr.email)
            contact.phone_numbers.new(name: 'Home', area_code: '000', phone1: '000', phone2: '0000')
            contact.address = Address.new(timezone: self.timezone)
            if contact.save
              appointment.contact_id = contact.id
            end
          end

          appointment.start_at = event.dtstart
          appointment.end_at = event.dtend
          contact.notes.create(:content => event.description, :user_id => curr_usr.id)
          if event.properties['rrule'].present?
            rec =  event.properties['rrule'][0].orig_value
            rule = Rule.from_ical(rec)
            recur = Schedule.new(event.dtstart, :end_time => event.dtstart)
            recur.add_recurrence_rule rule
            appointment.schedule = recur.to_hash
            appointment.repeat = 1
            appointment.from_ical = true
          end
          appointment.save!
        end
      end
    end
  end

  def block_single_appointment(appt_date, blocked_array,appointment_id)
    # for normal appointments
    appointments = self.appointments.where("Date(start_at) = ? AND `repeat` = ?", appt_date, false)
    appointments = appointments.where("id != ?", appointment_id) if appointment_id
    appointments.each do |appointment|
      blocked_array[appointment.start_at.in_time_zone(self.timezone)] = appointment.end_at.in_time_zone(self.timezone) - 1.minutes
    end
    return blocked_array
  end

  def block_recurring_appointment(appt_date, blocked_array, appointment_id)
    r_hash = Appointment.recurring_hash(Date.parse(appt_date), self.id)
    
    # r_hash for recurring appointments
    if r_hash[appt_date].present?
      r_hash[appt_date].values.each do |appt|
        if appointment_id 
          if r_hash[appt_date].keys[0] != appointment_id
            blocked_array[appt["start_time"].in_time_zone(self.timezone)] = appt["end_time"].in_time_zone(self.timezone)
          end
        else
          blocked_array[appt["start_time"].in_time_zone(self.timezone)] = appt["end_time"].in_time_zone(self.timezone)
        end
      end
    end
    return blocked_array
  end

  def find_time_interval
    time = Time.new(00)
    time_inter = []
    time_inter << time
    to = Time.new(00) + 23.hours + 59.minutes - self.apt_length.to_i.minutes
    begin
      time = time + self.apt_length.to_i.minutes
      time_inter << time
    end while time <= to
    return time_inter
  end

  def time_interval_array(appt_date, appointment_id = "")
    working_hour = self.calendar_hours
    tmp_date = appt_date.split("-")
    tmp_day = Date.new(tmp_date[0].to_i, tmp_date[2].to_i, tmp_date[1].to_i).strftime("%a").upcase
    appt_date = Date.new(tmp_date[0].to_i, tmp_date[2].to_i, tmp_date[1].to_i).strftime("%Y-%m-%d")
    blocked_array = Hash.new

    blocked_array = self.block_single_appointment(appt_date,blocked_array,appointment_id)
    blocked_array = self.block_recurring_appointment(appt_date,blocked_array,appointment_id)

    time_interval = []
    time_interval << find_time_interval << blocked_array.to_a
    return time_interval
  end

  def time_interval_block(from_time, to_time)
    time_inter = []
    time = Time.parse("0000-01-01 #{from_time}")
    time_inter << time
    to = Time.parse("0000-01-01 #{to_time}")
    begin
      time = time + self.apt_length.to_i.minutes
      time_inter << (time >= to ? (time - 1.minute) : time)
    end while time < to
    return time_inter
  end

  def self.to_ics(cal)
    appointments = Appointment.where(calendar_id: cal.id)

    calendar = Icalendar::Calendar.new

    calendar.prodid = "YesTrak"
    calendar.x_wr_calname = "Appointment Calendar (via YesTrak)"
    calendar.x_wr_timezone = cal.timezone

    appointments.each do |appointment|
      event = Icalendar::Event.new
      schedule = Schedule.from_hash(appointment.schedule.to_hash).to_ical + "\n"
      if appointment.schedule.present?
        event.add_event(schedule)
      else
        event.start = appointment.start_at.strftime("%Y%m%dT%H%M%S")
        event.end = appointment.end_at.strftime("%Y%m%dT%H%M%S")
      end
      event.summary = appointment.contact.notes.first.try(:content)
      event.description = appointment.contact.notes.first.try(:content)
      event.uid = (appointment.id).to_s + '@yestrak.com'
      calendar.add_event(event)
    end

    calendar.publish
    calendar.to_ical
  end

  def new_appt_time(appt_time)
    new_appt_time = (Time.parse("0000-01-01 #{appt_time}") + self.apt_length.to_i.minutes).strftime("%I:%M%P")
  end

  def create_blocked_timing(params)
    params[:status_class] == 'active' ? self.activate_time(params) : self.deactivate_time(params)
  end

  def activate_time(params)
    self.blocked_timings.create(appt_time: params[:appt_time], appt_date: params[:appt_date], status: 1)
    self.blocked_timings.create(appt_time: new_appt_time(params[:appt_time]), appt_date: params[:appt_date], status: 2)
  end

  def deactivate_time(params)
    self.blocked_timings.create(appt_time: params[:appt_time], appt_date: params[:appt_date], status: 0)
    self.blocked_timings.create(appt_time: new_appt_time(params[:appt_time]), appt_date: params[:appt_date], status: 3)
  end

  def valid_time?(start_time, end_time, appointment = "")
    working_hour = self.calendar_hours.find_by_hours_type("hours")
    @appt_window = self.calendar_hours.where("hours_type = ?", "windows")
    time_block = self.time_interval_block(start_time.strftime("%I:%M%P"), end_time.strftime("%I:%M%P"))
    available = ""
    time_block.each do |time|
      available = (working_hour.week_days.include?(start_time.to_date.strftime('%a').upcase) ? self.appointment_check_working_hours(time, working_hour) : "active") if available.blank?
      available = self.appointment_check_appt_window(time, start_time.to_date.strftime('%a').upcase) if available.blank?
      # (time = (time + 1.minute)) if (time_block[-1] == time)
      block = self.blocked_timings.find_by_appt_time_and_appt_date_and_status(time.strftime("%I:%M%P"), start_time.to_date.strftime('%Y-%d-%m'), [0, 3])
      (available = (block.status != 0 ? "" : "active")) if block.present?
      break if available.present?
    end
    if available == ""
      recurring = Appointment.recurring_hash(start_time)
      ids = recurring.values.map{|v| v.keys}.flatten.uniq
      ids.each do |id|
        appt = Appointment.find(id)
        recurring = (appt.repeat == true ? Schedule.from_hash(appt.schedule) : (IceCube::Schedule.new(appt.start_at, :end_time => appt.end_at - 1.minute)))
        if recurring.occurs_on?(Date.parse("#{start_time.strftime('%Y-%m-%d')}")) 
          recur = IceCube::Schedule.new(start_time, :end_time => end_time - 1.minute)
          if appointment.present?  
            available = "active" if (recurring.conflicts_with?(recur) && appointment.id != appt.id)
          else
            available = "active" if recurring.conflicts_with?(recur)
          end
        end
      end
      appointments = self.appointments.where("Date(CONVERT_TZ(start_at,'+00:00', '#{ActiveSupport::TimeZone.new(self.timezone.to_s).to_s[4,6]}')) = ? AND `repeat` = ?", start_time.strftime("%Y-%m-%d"), false)
      appointments.each do |app|
        s = (app.repeat == false ? (IceCube::Schedule.new(app.start_at, :end_time => app.end_at - 1.minute)) : Schedule.from_hash(app.schedule))
        if appointment.present?
          available = "active" if (s.occurring_between?(start_time, end_time - 1.minute) && appointment.id != app.id)
        else
          available = "active" if s.occurring_between?(start_time, end_time - 1.minute)
        end
      end
    end
    return available.blank?
  end

  def appointments_present?
    self.appointments.present?
  end

  def working_hours_check?(time)
    working_hour = self.calendar_hours.find_by_hours_type("hours")
    return true if (time >= Time.parse("0000-01-01 #{working_hour.start_time}")) && (time <= Time.parse("0000-01-01 #{working_hour.close_time}"))
    return false
  end

  def include_in_working_days?(day)
    self.calendar_hours.find_by_hours_type("hours").week_days.include?(day)
  end
end
