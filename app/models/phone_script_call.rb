class PhoneScriptCall < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :campaign_id, uniqueness: {scope: [:call_time, :talk_time, :hold_time]}
  belongs_to :tenant
  belongs_to :phone_script, :foreign_key => 'campaign_id', :primary_key => 'campaign_id'


  #scope :over_100_minutes, where(is_read: false).select('SUM(total_time) AS total_min, tenant_id')
  #                         .having('total_min > 100').group(:tenant_id)
  #scope :unread_minutes, lambda { |tenant_id| where(tenant_id: tenant_id, is_read: false)
  #                                            .select('SUM(total_time) AS total_min') }
  scope :unread_records, select('SUM(total_time) AS total_min, tenant_id')
                         .group(:tenant_id).where(is_read: false).where('tenant_id IS NOT NULL')

  def self.mark_as_read!
    update_all(is_read: true)
  end

  def self.update_tenant_call_minutes!
    records = unread_records
    records.each do |i|
      query = "UPDATE `tenants` SET `call_minutes` = COALESCE(`call_minutes`, 0) + #{i.total_min} WHERE `tenants`.`id` = #{i.tenant_id}"
      ActiveRecord::Base.connection.execute(query)
    end
    records.mark_as_read! if records.present?
  end

end
