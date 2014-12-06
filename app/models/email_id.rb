class EmailId < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  belongs_to :mailable, polymorphic: true
  attr_protected :tenant_id

  validates :tenant_id, :mailable_type, presence: true
  validates :emails, uniqueness: {scope: [:mailable_id, :mailable_type]}

end