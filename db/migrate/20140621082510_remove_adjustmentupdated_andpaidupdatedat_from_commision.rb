class RemoveAdjustmentupdatedAndpaidupdatedatFromCommision < ActiveRecord::Migration
  def change
    remove_column :commissions, :adjustment_updated_at
    remove_column :commissions, :paid_updated_at
  end
end
