class RenameColumnCorrectionToCommission < ActiveRecord::Migration
  def change
    rename_column :commissions, :correction, :adjustment
  end
end
