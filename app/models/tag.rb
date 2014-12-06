class Tag < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  attr_accessible :name, :color
  # validates :name, presence: true
  # validates :color, presence: true

  belongs_to :tenant
  has_many   :contact_tags, dependent: :destroy
  has_many   :contacts, through: :contact_tags
end
