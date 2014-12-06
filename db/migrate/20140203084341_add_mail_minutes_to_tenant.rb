class AddMailMinutesToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :menu_sec, :integer, default: 0, null: false, :after => :plan_bid
    add_column :tenants, :mail_sec, :integer, default: 0, null: false, :after => :plan_bid

    change_column :tenants, :call_minutes, :integer, default: 0, null: false
    rename_column :tenants, :call_minutes, :call_sec
  end
end
