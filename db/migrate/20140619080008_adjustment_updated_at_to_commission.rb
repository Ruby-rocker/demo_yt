class AdjustmentUpdatedAtToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :adjustment_updated_at, :timestamp
  end
end
