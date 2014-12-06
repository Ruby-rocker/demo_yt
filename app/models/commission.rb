class Commission < ActiveRecord::Base
  attr_accessible :commission, :is_paid, :partner_master_id, :user_id, :adjustment
  validates :adjustment,:numericality => {only_integer: true }
  belongs_to :partner_master
  extend CustomFilter
   cattr_accessor :displaying_range
   scope :super_user_notifications, order('created_at DESC')
end
