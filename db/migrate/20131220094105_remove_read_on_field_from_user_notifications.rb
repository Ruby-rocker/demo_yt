class RemoveReadOnFieldFromUserNotifications < ActiveRecord::Migration
  def up
  	remove_column :user_notifications, :read_on
  end

  def down
  end
end
