class CreateTenantNotifications < ActiveRecord::Migration
  def change
    create_table :tenant_notifications do |t|
      t.references :tenant
      t.boolean :pay_as_you_go, :default => false, :null => false
      t.boolean :minutes200, :default => false, :null => false

      t.timestamps
    end

    add_index :tenant_notifications, :tenant_id
  end
end
