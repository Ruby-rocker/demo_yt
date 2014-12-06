module AppointmentsHelper
	include IceCube
  def recurring_select(appointment)
    if appointment.repeat? && appointment.schedule.present?
      if appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Yearly')
        str = ['yearly']
      elsif appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Daily') && appointment.schedule[:rrules][0][:interval].present? && appointment.schedule[:rrules][0][:interval] == 1
        str = ['daily']
      elsif appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Daily') && appointment.schedule[:rrules][0][:interval].present? && appointment.schedule[:rrules][0][:interval] > 1
        str = ['periodically',appointment.schedule[:rrules][0][:interval]]
      elsif appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Weekly') && appointment.schedule[:rrules][0][:validations][:day].present?
        str = ['weekly',appointment.schedule[:rrules][0][:validations][:day][0]]
      elsif appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Monthly') && appointment.schedule[:rrules][0][:validations][:day_of_month].present?
        str = ['monthly',appointment.schedule[:rrules][0][:validations][:day_of_month][0]]
      elsif appointment.schedule[:rrules][0].present? && appointment.schedule[:rrules][0][:rule_type].include?('Monthly')
        str = ['monthly']
      else
        str = ['never']
      end
    else
      str = ['never']
    end
    return str
  end

  def create_schedule(start_at, end_at, repeat_frequency, interval)
    IceCube::Schedule.new(start_at, end_time: end_at) do |s|
      if repeat_frequency == "daily"
        s.add_recurrence_rule(Rule.daily.until(Time.now + 2.years))
      elsif repeat_frequency == "periodically"
        s.add_recurrence_rule(Rule.daily(interval).until(Time.now + 2.years))
      elsif repeat_frequency == "weekly"
        s.add_recurrence_rule(Rule.weekly(interval).until(Time.now + 2.years))
      elsif repeat_frequency == "monthly"
        s.add_recurrence_rule(Rule.monthly.day_of_month(interval).until(Time.now + 2.years))
      elsif repeat_frequency == "yearly"
        s.add_recurrence_rule(Rule.yearly.until(Time.now + 2.years))
      end
    end
  end

  def recurring_terminating(appointment)
    if appointment.schedule.present?
      schedule = Schedule.from_hash(appointment.schedule)
      return schedule.terminating? && schedule.recurrence_rules.present?
    end
    return false
  end

end
