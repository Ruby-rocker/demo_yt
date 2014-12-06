class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :tenant
      t.references :notifiable, polymorphic: true
      t.string :title
      t.boolean :is_read, default: false, null: false
      t.text :content
      t.datetime :notify_on

      t.timestamps
    end
    add_index :notifications, :tenant_id
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end
end
