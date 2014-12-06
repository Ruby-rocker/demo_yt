class RanameRableNameFromUnreadNotificationToUserNotifications < ActiveRecord::Migration
  def up
  	rename_table :unread_notifications, :user_notifications
  end

  def down
  	rename_table :user_notifications, :unread_notifications
  end
end
