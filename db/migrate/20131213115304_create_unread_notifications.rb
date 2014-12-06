class CreateUnreadNotifications < ActiveRecord::Migration
  def change
    create_table :unread_notifications do |t|
      t.references :user
      t.references :notification
      t.boolean :is_read, default: false, null: false
      t.datetime :read_on

      t.timestamps
    end
    add_index :unread_notifications, :user_id
    add_index :unread_notifications, :notification_id
  end
end
