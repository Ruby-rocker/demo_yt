class PhoneScriptHour < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  store :first_mon, accessors: [ :first_mon_open, :first_mon_close ]
  store :first_tue, accessors: [ :first_tue_open, :first_tue_close ]
  store :first_wed, accessors: [ :first_wed_open, :first_wed_close ]
  store :first_thu, accessors: [ :first_thu_open, :first_thu_close ]
  store :first_fri, accessors: [ :first_fri_open, :first_fri_close ]
  store :first_sat, accessors: [ :first_sat_open, :first_sat_close ]
  store :first_sun, accessors: [ :first_sun_open, :first_sun_close ]

  store :second_mon, accessors: [ :second_mon_open, :second_mon_close ]
  store :second_tue, accessors: [ :second_tue_open, :second_tue_close ]
  store :second_wed, accessors: [ :second_wed_open, :second_wed_close ]
  store :second_thu, accessors: [ :second_thu_open, :second_thu_close ]
  store :second_fri, accessors: [ :second_fri_open, :second_fri_close ]
  store :second_sat, accessors: [ :second_sat_open, :second_sat_close ]
  store :second_sun, accessors: [ :second_sun_open, :second_sun_close ]

  #store :day_status, accessors: [ :mon_stat, :tue_stat, :wed_stat, :thu_stat, :fri_stat, :sat_stat, :sun_stat ]
  store :day_status, accessors: [ :normal, :mon_stat, :tue_stat, :wed_stat, :thu_stat, :fri_stat, :sat_stat, :sun_stat ]
  attr_protected :tenant_id

  belongs_to :tenant
  belongs_to :phone_script

  DAYNAMES = %w(mon tue wed thu fri sat sun)
  HOURS = 2
  OPEN  = 1
  CLOSE = 0

  DAY_STATUS = {'Select Hours' => HOURS, 'Open all day' => OPEN, 'Closed all day' => CLOSE}

  after_save :xps_buss_hours, if: 'phone_script.try(:campaign_id)'

  private ##########################################################

  def xps_buss_hours
    CallCenter::XpsUsa.buss_hours(phone_script_id, tenant_id)
  end

end