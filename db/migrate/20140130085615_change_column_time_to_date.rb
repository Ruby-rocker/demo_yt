class ChangeColumnTimeToDate < ActiveRecord::Migration
  def change
    change_column :tenants, :next_due, :date
    change_column :add_ons, :next_due, :date
  end
end
