ActiveAdmin.register TenantConfig do
	menu :priority => 1, :parent => "Tenants"
  actions :all, :except => [:destroy,:new, :edit, :create, :update]
  filter :discount_minutes

	index do
		h4 "Available call minutes: #{current_tenant.call_minutes.to_i}"
		column :credit_for
		column :discount_minutes
		column :created_at
    default_actions
	end

	show :title => "Show Tenant Configuration" do |ad|
		attributes_table do
			row :id
      row :tenant
			row :credit_for
			row :discount_minutes
			row :created_at
			row :updated_at
		end
	end

	form :partial => "admin/tenant_configs/form"
	controller do
		def new
			@tenant_config = TenantConfig.new
		end

		def create
			@tenant_config = TenantConfig.new(params[:tenant_config])
			respond_to do |format|
        	if @tenant_config.save
	          if params[:tenant_config][:credit_for] == "PhoneScript"
	            @update_tenant = current_tenant
	            @update_tenant.credit_minutes = @update_tenant.credit_minutes + @tenant_config.discount_minutes
	            @update_tenant.save!
	          end
	          if params[:tenant_config][:credit_for] == "PhoneMenu"
	            @update_tenant = current_tenant
	            @update_tenant.credit_menu_minutes = @update_tenant.credit_menu_minutes + @tenant_config.discount_minutes
	            @update_tenant.save!
	          end
	          if params[:tenant_config][:credit_for] == "Voicemail"
	            @update_tenant = current_tenant
	            @update_tenant.credit_mail_minutes = @update_tenant.credit_mail_minutes + @tenant_config.discount_minutes
	            @update_tenant.save!
	          end
	          if @tenant_config.discount_minutes > 0
	            AdminMailer.delay.credit_minutes_added(@tenant_config.discount_minutes, @update_tenant.subdomain, @update_tenant.owner.email, @tenant_config.created_at, @update_tenant.timezone)
	          end
				format.html { redirect_to tenant_configs_path, notice: "Log created successfully" }
			else
				format.html { render action: "new" }
			end
			end
		end
	end
end
