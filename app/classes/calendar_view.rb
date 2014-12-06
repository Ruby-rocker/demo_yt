class CalendarView

  #TIME_ZONE = 'Eastern Time (US & Canada)'

  def initialize
    @today = Time.zone.today
  end

  class << self

    # get a week
    def set_week(date=nil)
      date = date ? Date.parse(date.to_s) : Time.zone.today
      week = date.wday
      start_day = date.prev_day(week)
      end_day = date.next_day(6-week)
      return start_day.step(end_day).to_a
    end

    # get calendar month
    def set_month(year=nil, month=1)
      if year
        date = Date.civil(year.to_i,month.to_i)
      else
        date = Time.zone.today.beginning_of_month
      end
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

  end

end