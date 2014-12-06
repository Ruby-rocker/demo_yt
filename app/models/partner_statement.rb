class PartnerStatement < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :partner_master
  extend CustomFilter
   cattr_accessor :displaying_range
   scope :super_user_notifications, order('created_at DESC')
end
