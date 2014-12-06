class AddCorrectionToCommissions < ActiveRecord::Migration
  def change
    add_column :commissions, :correction, :integer
  end
end
