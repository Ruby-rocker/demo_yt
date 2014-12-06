class ContactTag < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  belongs_to :contact
  belongs_to :tag
  belongs_to :user
end
