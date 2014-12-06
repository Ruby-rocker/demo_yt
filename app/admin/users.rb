ActiveAdmin.register User, :as => "SiteUser" do
  menu :priority => 10, :label => "Users"
  actions :all, :except => [:destroy, :new, :edit]

  filter :first_name
  filter :last_name
  filter :subdomain
  filter :email
  filter :role
  filter :status
  filter :last_sign_in_at
  filter :last_sign_in_ip
  filter :confirmed_at

  member_action :login, :method => :put do
    user = User.find(params[:id])
    redirect_to login_from_admin_url(user.authentication_token, subdomain: current_tenant.subdomain)
  end

  action_item :only => [:show] do
    link_to('Login', login_site_user_path(site_user), method: :put, target: :blank) if site_user.is_service_user?
  end

  index do
    column :first_name
    column :last_name
    column :subdomain
    column :email
    column :plan_bid
    column :role
    column :status

    actions defaults: true do |user|
      link_to('Login', login_site_user_path(user), class: "member_link", method: :put, target: :blank) if user.is_service_user?
    end
  end

  show do
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row :subdomain
      row :role
      row :email
      row :reset_password_sent_at
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :confirmation_token
      row :confirmed_at
      row :confirmation_sent_at
      row :unconfirmed_email
      row :created_at
      row :updated_at
      row :status
    end
    # active_admin_comments
  end

  form do |f|
    f.inputs "User Details" do
      f.input :first_name
      f.input :last_name
      f.input :subdomain, :required => true
      f.input :email
      # f.input :password, :required => true
      # f.input :password_confirmation, :required => true
      f.input :status, hint: site_user.id ? '' : 'active user without subscription', input_html: { :disabled => true }
    end
    f.actions
  end

  controller do
  end
end
