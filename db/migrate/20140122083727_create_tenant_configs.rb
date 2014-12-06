class CreateTenantConfigs < ActiveRecord::Migration
  def change
    create_table :tenant_configs do |t|
      t.references   :tenant
      t.integer      :plan1, default: 0
      t.integer      :plan2, default: 0
      t.integer      :plan3, default: 0
      t.timestamps
    end

    add_index :tenant_configs, :tenant_id, :unique => true

  end
end
