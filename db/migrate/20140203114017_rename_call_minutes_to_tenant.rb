class RenameCallMinutesToTenant < ActiveRecord::Migration
  def change
    rename_column :tenants, :call_sec, :call_minutes
    rename_column :tenants, :menu_sec, :menu_minutes
    rename_column :tenants, :mail_sec, :mail_minutes
  end
end
