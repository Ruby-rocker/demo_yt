module CalendarsHelper
	def check_availability(time, blocked_hash)
		blocked_hash.each do |key, val|
			return "active" if (val.strftime("%I:%M%P") == time.strftime("%I:%M%P"))
			ary = []
			ary << Time.parse("0000-01-01 #{key.strftime("%I:%M%P")}").to_s
			ary << Time.parse("0000-01-01 #{val.strftime("%I:%M%P")}").to_s
			ary << time.to_s
			ary = ary.sort
			return "active" if (ary[1] == time.to_s)
		end
		return ""
	end

	def check_working_hours(time, working_hour)
		blocked_hash = Hash.new
		blocked_hash[Time.parse("0000-01-01 #{working_hour.start_time}")] = Time.parse("0000-01-01 #{working_hour.close_time}")
		return (check_availability(time, blocked_hash).present? ? "" : "active")
	end

	def check_appt_window(time, day)
		availability = []
		@appt_window.each do |appt_window|
			if time.strftime("%I:%M%P") == Time.parse("0000-01-01 #{appt_window.close_time}").strftime("%I:%M%P")
				availability << "active"
			else	
				availability << (appt_window.week_days.include?(day) ? check_working_hours(time, appt_window) : "active")
			end
		end
		return availability.include?("") ? "" : "active"
	end

	def check_status(time, date, calendar_id)
		block = BlockedTiming.find_by_appt_time_and_appt_date_and_calendar_id(time, date, calendar_id)
		if block.present?
			return block.status ? nil : "active"
		end
	end

	def appointment_check_availability(time, blocked_hash)
		blocked_hash.each do |key, val|
			return "" if (val.strftime("%I:%M%P") == time.strftime("%I:%M%P"))
			ary = []
			ary << Time.parse("0000-01-01 #{key.strftime("%I:%M%P")}").to_s
			ary << Time.parse("0000-01-01 #{val.strftime("%I:%M%P")}").to_s
			ary << time.to_s
			ary = ary.sort
			return "active" if (ary[1] == time.to_s)
		end
		return ""
	end

	def appointment_check_working_hours(time, working_hour)
		blocked_hash = Hash.new
		blocked_hash[Time.parse("0000-01-01 #{working_hour.start_time}")] = Time.parse("0000-01-01 #{working_hour.close_time}")
		return (appointment_check_availability(time, blocked_hash).present? ? "" : "active")
	end

	def appointment_check_appt_window(time, day)
		availability = []
		@appt_window.each do |appt_window|
      availability << (appt_window.week_days.include?(day) ? appointment_check_working_hours(time, appt_window) : "active")
    end
    return availability.include?("") ? "" : "active"
	end

	def set_time(time)
		Time.parse("0000-01-01 #{time}")
	end

	def find_calendars(calendar_id = nil)
		calendar_id.present? ? Calendar.where(id: calendar_id) : Calendar.all
	end

	def calendar_checkbox(calendar, appointment_search_date = nil)
		#abort calendar.inspect
    # content_tag(:input, type: "check_box"){} +
    link_to "javascript:;", class: "view_cal", id: "view_cal_#{calendar.id}", onclick: "submit_through_link(this)" do
    	#content_tag(:span, class: 'color', style: "background-color:#{calendar.color};"){} +
    	calendar.name
    end
  end
end
