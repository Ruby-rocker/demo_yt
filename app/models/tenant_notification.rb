class TenantNotification < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  attr_protected :tenant_id
end