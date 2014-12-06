class AddDiscountMinutesToTenantConfig < ActiveRecord::Migration
  def change
    add_column :tenant_configs, :discount_minutes, :integer
  end
end
