class AddFromAdminToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :from_admin, :boolean, default: false, null: false, :after => :menu_minutes
    remove_column :users, :from_admin
  end
end
