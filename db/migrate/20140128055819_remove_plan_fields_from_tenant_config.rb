class RemovePlanFieldsFromTenantConfig < ActiveRecord::Migration
  def up
  	remove_column :tenant_configs, :plan_pay_as_you_go
  	remove_column :tenant_configs, :plan_200_minutes
  	remove_column :tenant_configs, :plan_500_minutes
  end

  def down
  end
end
