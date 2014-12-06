ActiveAdmin.register PhoneMenu do
	menu :priority => 1, :label => "Phone Menu", :parent => "AllTenant"
  actions :all, :except => [:destroy,:new, :edit, :create, :update]

  filter :tenant
  filter :name
  index do
    #column "ViziCall Campaign ID", :id
    column :id
    column :name
    column :tenant
    column :business
		#column :is_deleted

    default_actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :business
      row :tenant
      row :created_at
      row :updated_at
    end
  end
  controller do
    before_filter :reset_tenant

    skip_before_filter :decide_redirection

    def scoped_collection
      PhoneMenu.unscoped
    end

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end
  
end
