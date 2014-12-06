ActiveAdmin.register Help, :as => "AllHelp" do
  menu :priority => 11, :label => "Help"
	# filter :tenant
  filter :user
  filter :question

  index do
    column :question
    column :details
    default_actions
  end

  show :title => "Help" do |help|
    attributes_table do
      row :id
      row :tenant
      row :question
      row :details
      row :user
      row :first_name
      row :last_name
      row :area_code
      row :phone1
      row :phone2
      row :email
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Help" do
      f.input :question
      # f.input :tenant, :as => "select", :collection => Tenant.active_tenants_only.map{|t| [ "#{if t.subdomain then t.subdomain else "User not set" end}", t.subdomain ]}#, {prompt: 'Select Tenant', :selected => "#{tenant}"}
      f.input :details
      f.input :first_name
      f.input :last_name
      f.input :area_code
      f.input :phone1
      f.input :phone2
      f.input :email
    end
    f.actions
  end

  # form :partial => "admin/helps/form"
  controller do
    before_filter :reset_tenant

    skip_before_filter :decide_redirection

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end
end