ActiveAdmin.register CreditAmount do
	config.clear_action_items!
	menu :priority => 1, :parent => "Tenants"
	filter :amount
	index do
		column :tenant_id
		column :amount
		column :created_at
		column :updated_at
	end
	controller do
		before_filter :reset_tenant

    skip_before_filter :decide_redirection

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end
  
end
