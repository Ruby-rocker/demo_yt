class ChangeFieldOfTenantCancellationTable < ActiveRecord::Migration
  def up
  	rename_column :tenant_cancellations, :reason_to_cancel, :reason_master_id
  	change_column :tenant_cancellations, :reason_master_id, :integer
    add_column :tenant_cancellations, :other_reason, :string
  end

  def down
  end
end
