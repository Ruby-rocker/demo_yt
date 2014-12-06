class PartnerStat < ActiveRecord::Base
  attr_accessible :clicks, :ip_address, :partner_master_id
  belongs_to :partner_master
   extend CustomFilter
   cattr_accessor :displaying_range
   scope :super_user_notifications, order('created_at DESC')
end
