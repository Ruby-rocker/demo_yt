class SubscriptionLog < ActiveRecord::Base
  acts_as_tenant(:tenant)
  attr_protected :tenant_id

  belongs_to :tenant
  has_many   :add_on_logs, as: :chargeable


  private ##################################

end
