module CustomFilter
  DATE_RANGE = { 'today' => 'Today', 'yesterday' => 'Yesterday', 'last_7_days' => 'Last 7 Days',
                 'this_week' => 'This Week', 'previous_week' => 'Previous Week', 'last_30_days' => 'Last 30 Days',
                 'this_month' => 'This Month', 'previous_month' => 'Previous Month',
                 'previous_3_months' => 'Previous 3 Months', 'previous_6_months' => 'Previous 6 Months',
                 'this_year' => 'This Year', 'previous_year' => 'Previous Year' }

  def filter(search=nil, staff=nil, controller_type=nil)
    self.displaying_range  = nil
    if !controller_type
      if staff
        result_list = staff_notifications
      else
        result_list = super_user_notifications
      end
    elsif controller_type == "call_recordings" || controller_type == "voicemail" 
      result_list = super_user_notifications
    end
    if search
      if search[:date].present?
        range = date_filter(search[:date])
        case search[:date]
          when 'today', 'yesterday'
            self.displaying_range = 'Currently Viewing: ' + range.strftime('%-m/%-d/%y')
            if controller_type == "call_recordings" || controller_type == "voicemail" 
              result_list = result_list.where('DATE(recordings.created_at) = ?', range)
            else
              result_list = result_list.where('DATE(created_at) = ?', range)
            end
          when 'this_year', 'previous_year', 'last_7_days', 'last_30_days', 'this_week', 'previous_week', 'this_month', 'previous_month', 'previous_3_months', 'previous_6_months'
            self.displaying_range = 'Currently Viewing: ' + range.map {|i| i.strftime('%-m/%-d/%y') }.join(' to ')
            if controller_type == "call_recordings" || controller_type == "voicemail" 
              result_list = result_list.where('DATE(recordings.created_at) BETWEEN ? AND ?', range.first, range.last)
            else
              result_list = result_list.where('DATE(created_at) BETWEEN ? AND ?', range.first, range.last)
            end
        end
      end  # search[:date].present?
      if search[:date_from].present? && search[:date_to].present?
        search[:date_from] = search[:date_from].to_date
        search[:date_to] = search[:date_to].to_date
        self.displaying_range = 'Currently Viewing: ' + [search[:date_from], search[:date_to]].map {|i| i.strftime('%-m/%-d/%y') }.join(' to ')
        if controller_type == "call_recordings" || controller_type == "voicemail" 
          result_list = result_list.where('DATE(recordings.created_at) BETWEEN ? AND ?', search[:date_from], search[:date_to])
        else
          result_list = result_list.where('DATE(created_at) BETWEEN ? AND ?', search[:date_from], search[:date_to])
        end
      end
    end  # search[:phone_script].present?   

    result_list
  end

  def filter_for_partner(search=nil, staff=nil, controller_type=nil)
    self.displaying_range  = nil
    if !controller_type
      if staff
        result_list = staff_notifications
      else
        result_list = super_user_notifications
      end
    elsif controller_type == "partners_stats" || controller_type == "partners_statements"
      result_list = super_user_notifications
    end
    if search
      if search[:date].present?
        range = date_filter(search[:date])
        case search[:date]
          when 'today', 'yesterday'
            self.displaying_range = 'Currently Viewing: ' + range.strftime('%-m/%-d/%y')
              if controller_type == "partners_stats"
                result_list = result_list.where('DATE(updated_at) = ?', range)
              else
                result_list = result_list.where('DATE(created_at) = ?', range)
              end
          when 'this_year', 'previous_year', 'last_7_days', 'last_30_days', 'this_week', 'previous_week', 'this_month', 'previous_month', 'previous_3_months', 'previous_6_months'
            self.displaying_range = 'Currently Viewing: ' + range.map {|i| i.strftime('%-m/%-d/%y') }.join(' to ')
              if controller_type == "partners_stats" 
                result_list = result_list.where('DATE(updated_at) BETWEEN ? AND ?', range.first, range.last)
              else
                result_list = result_list.where('DATE(created_at) BETWEEN ? AND ?', range.first, range.last)
              end
        end
      end  # search[:date].present?
      if search[:date_from].present? && search[:date_to].present?
        search[:date_from] = search[:date_from].to_date
        search[:date_to] = search[:date_to].to_date
        self.displaying_range = 'Currently Viewing: ' + [search[:date_from], search[:date_to]].map {|i| i.strftime('%-m/%-d/%y') }.join(' to ')
          if controller_type == "partners_stats"
            result_list = result_list.where('DATE(updated_at) BETWEEN ? AND ?', search[:date_from], search[:date_to])
          else
            result_list = result_list.where('DATE(created_at) BETWEEN ? AND ?', search[:date_from], search[:date_to])
          end
      end
    end  # search[:phone_script].present?   

    result_list
  end

  def date_filter(filter)
    date = Time.zone.today
    case filter
      when 'today'
        return date
      when 'yesterday'
        return date.yesterday
      when 'last_7_days'
        return date - 7.day, date - 1.day
      when 'last_30_days'
        return date - 30.day, date - 1.day
      when 'this_week'
        week = CalendarView.set_week(date)
        return week.first, week.last
      when 'previous_week'
        week = CalendarView.set_week(date)
        return week.first - 7.days, week.first - 1.days
      when 'this_month'
        return date.beginning_of_month, date.end_of_month
      when 'previous_month'
        date = date << 1
        return date.beginning_of_month, date.end_of_month
      when 'previous_3_months'
        return (date << 3).beginning_of_month, (date >> 1).end_of_month
      when 'previous_6_months'
        return (date << 6).beginning_of_month, (date >> 1).end_of_month
      when 'this_year'
        #return date.year
        return "1 jan #{date.year}".to_date, "31 dec #{date.year}".to_date
      when 'previous_year'
        #return date.year - 1
        return "1 jan #{date.year-1}".to_date, "31 dec #{date.year-1}".to_date
    end
  end

  def filter_by_phone_script(search=nil)
    if search
      @recordings = select("recordings.*").joins(
      "INNER JOIN phone_scripts ON phone_scripts.id = twilio_numbers.twilioable_id").where(
      "twilio_numbers.twilioable_type = 'PhoneScript' AND phone_scripts.name like '%#{search[:phone_script]}%'")
      return @recordings
    end
  end
  def filter_by_voicemail(search=nil)
    if search
      @recordings = select("recordings.*").joins(
      "INNER JOIN voicemail ON voicemail.id = twilio_numbers.twilioable_id").where(
      "twilio_numbers.twilioable_type = 'Voicemail' AND voicemail.name like '%#{search[:voicemail]}%'")
      return @recordings
    end
  end
end