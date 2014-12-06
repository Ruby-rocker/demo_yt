class AddPaidUpdatedAtToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :paid_updated_at, :timestamp
  end
end
