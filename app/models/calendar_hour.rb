class CalendarHour < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  attr_protected :tenant_id
  attr_accessible :close_time, :start_time, :hours_type, :week_days

  belongs_to :tenant
  belongs_to :calendar

  SUN = 0
  MON = 1
  TUE = 2
  WED = 3
  THU = 4
  FRI = 5
  SAT = 6

  DAYS_NAME = %w{SUN MON TUE WED THU FRI SAT}

  validates :hours_type, inclusion: { in: %w(hours windows) }
  serialize :week_days, Array
  before_validation :set_week_days

  def get_week_days
    week_days.join(', ')
  end

  private ####################################

  def set_week_days
    if week_days.present?
      self.week_days = [week_days].flatten.map(&:strip)
    else
      self.week_days = nil
    end
  end

end
