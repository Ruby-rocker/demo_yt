class RemoveIndexFromTenantConfig < ActiveRecord::Migration
  def up
  	remove_index :tenant_configs, :tenant_id
  end

  def down
  end
end
