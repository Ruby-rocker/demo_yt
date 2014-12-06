class UserNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification
  attr_accessible :user_id

  validates :notification_id, :user_id, presence: true
  #validates :notification_id, uniqueness: {scope: :user_id}
  scope :notifications_id, select("DISTINCT notification_id")
end
