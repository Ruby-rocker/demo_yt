class RenameColumnNamesForTenantConfig < ActiveRecord::Migration
  def up
    rename_column :tenant_configs, :plan1, :plan_pay_as_you_go
    rename_column :tenant_configs, :plan2, :plan_200_minutes
    rename_column :tenant_configs, :plan3, :plan_500_minutes
  end

  def down
  end
end
