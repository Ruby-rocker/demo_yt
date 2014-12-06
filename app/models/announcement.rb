class Announcement < ActiveRecord::Base
  attr_accessible :message, :user_id, :via_email, :via_sms
  belongs_to :user
end
