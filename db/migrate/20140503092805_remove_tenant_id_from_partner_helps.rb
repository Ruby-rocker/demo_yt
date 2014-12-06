class RemoveTenantIdFromPartnerHelps < ActiveRecord::Migration
  def up
  	remove_column :partner_helps, :tenant_id
  end

  def down
  end
end
