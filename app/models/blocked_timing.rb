class BlockedTiming < ActiveRecord::Base
  acts_as_tenant(:tenant)

  attr_protected :tenant_id
  belongs_to :tenant
  belongs_to :calendar

  delegate :new_appt_time, :to => :calendar 

  def update_block(params)
    if self.status == 1
      self.update_attributes(status: 0)
  		BlockedTiming.find_by_calendar_id_and_appt_time_and_appt_date_and_status(params[:calendar_id], new_appt_time(params[:appt_time]), params[:appt_date], 2).update_attributes(status: 3)
  	else
  		self.update_attributes(status: 1)
      with_status_3 = BlockedTiming.find_by_calendar_id_and_appt_time_and_appt_date_and_status(params[:calendar_id], new_appt_time(params[:appt_time]), params[:appt_date], 3)
      if with_status_3.present?
        with_status_3.update_attributes(status: 2)
      else
        BlockedTiming.create(calendar_id: params[:calendar_id], appt_time: new_appt_time(params[:appt_time]), appt_date: params[:appt_date], status: 2)
      end
  	end
  end
end
