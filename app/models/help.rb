class Help < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  belongs_to :user
  has_many :notifications, as: :notifiable

  attr_protected :tenant_id
end
