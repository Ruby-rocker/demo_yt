class RemoveColumnIsReadFromUserNotificationsTable < ActiveRecord::Migration
  def up
  	remove_column :user_notifications, :is_read
  	add_index :user_notifications, :user_id
	add_index :user_notifications, :notification_id
  end

  def down
  end
end
