ActiveAdmin.register Tenant do
  menu :priority => 3
  actions :all, :except => [:destroy, :update, :edit]
  member_action :credit_amount, :method => :get do
    @tenant_id = params[:id]
    @credit_amount = CreditAmount.new(amount: 0)
    render 'admin/credit_amounts/_credit_amount.html.haml'
  end

  collection_action :save_amount, :method => :post do
    #raise params.inspect
    ActsAsTenant.current_tenant = nil
    @credit_amount = CreditAmount.new(:tenant_id => params[:credit_amount][:tenant_id], :amount => params[:credit_amount][:amount])
      respond_to do |format|
        if @credit_amount.save
          format.html {redirect_to credit_amounts_path}
        else
          @tenant_id = params[:credit_amount][:tenant_id]
          format.html {render 'admin/credit_amounts/_credit_amount/'}
        end
      end
  end

	index do
    #column :id
		column :subdomain
    column :call_minutes
    column :menu_minutes
    column :mail_minutes
    column :credit_minutes
    #column :customer_bid
    #column :has_paid
    column :next_due
    #column :timezone
    column :status, :sortable => "tenants.status" do |s|
      if s.status == "active"
        "Active"
      else
        "Inactive"
      end
    end
    column :plan_bid

    #default_actions
    actions  defaults: :true do |tenant|
      link_to('Credit', credit_amount_tenant_path(tenant), class: "member_link", method: :get)
    end
  end

  #action_item :only => [:index] do
  #  link_to('Announcement / Notification', '#' , method: :get)
  #end

  show :title => "Tenant" do |tenant|
    attributes_table do
      row :id
      row :subdomain
      row :call_minutes
      row :credit_minutes
      row :customer_bid
      row :subscription_bid
      row :has_paid
      row :next_due
      row :timezone
      row :plan_bid
      row :status
      row :mail_minutes
      row :menu_minutes
    end
  end

  filter :subdomain
  filter :next_due
  filter :status
  filter :call_minutes
  filter :menu_minutes
  filter :mail_minutes
  filter :credit_minutes

  #collection_action :change_tenant, :method => :get do
  #  Tenant.find_by_subdomain(params[:tenant][:subdomain]).set_as_active
  #  session[:selected_tenant] = params[:tenant][:subdomain]
  #  redirect_to site_users_path
  #end

  collection_action :change_tenant, :method => :get do
    if params[:search].present?
      tenant = Tenant.find_by_subdomain(params[:search])
      if tenant
        tenant.set_as_active
        session[:selected_tenant] = params[:search]
        redirect_to site_users_path
      else
        flash.alert = 'Invalid tenant name'
        redirect_to dashboard_path
      end
    else
      tenant = Tenant.find_by_subdomain(params[:tenant][:subdomain])
      if tenant
        tenant.set_as_active
        session[:selected_tenant] = params[:tenant][:subdomain]
        redirect_to site_users_path
      else
        flash.alert = 'Invalid tenant name'
        redirect_to dashboard_path
      end
    end
  end

  collection_action :autocomplete_tenant_subdomain, :method => :get

  form do |f|
    f.inputs "Tenant Details" do
      f.input :subdomain, :required => true
      f.input :status, hint: 'active user without subscription', input_html: { :disabled => true }
      f.input :timezone, as: :time_zone, priority_zones: ActiveSupport::TimeZone.us_zones
    end

    f.inputs "User Details", :for => [:owner, f.object.owner] do |user|
      user.input :first_name
      user.input :last_name
      user.input :email
      user.input :password, :required => true
      user.input :password_confirmation, :required => true
    end

    f.inputs "Business Details", :for => [:business, f.object.businesses.first] do |business|
      business.input :name
      business.input :website
      business.input :description, input_html: { style: "height: 50px;" }
      business.input :landmark, input_html: { style: "height: 50px;" }
      #f.semantic_fields_for(f.object.businesses.first.phone_number) do |p|
      f.semantic_fields_for(:phone_number) do |p|
        #business.form_buffers.last << p.input(:area_code, label: 'Phone Number', input_html: {maxlength: 3, style: "width: 50px;" })
        #business.form_buffers.last << p.input(:phone1, label: false, input_html: { style: "width: 50px;" })
        #business.form_buffers.last << p.input(:phone2, label: false, input_html: { style: "width: 50px;" })

        #business.form_buffers.last << p.input(:area_code, label: 'Phone Number', input_html: {maxlength: 3, style: "width: 50px;" })
        #business.form_buffers.last << p.input(:phone1, label: false, input_html: { style: "width: 50px;" })
        #business.form_buffers.last << p.input(:phone2, label: false, input_html: { style: "width: 50px;" })
        #business.form_buffers.last << "<li id='tenant_business_phone_number_attributes_area_code_input' class='string input required stringish'><label for='tenant_business_phone_number_attributes_area_code' class=' label'>Phone Number<abbr title='required'>*</abbr></label> <input type='text' style='width: 50px;' name='tenant[business][phone_number_attributes][area_code]' maxlength='3' id='tenant_business_phone_number_attributes_area_code'> <input type='tel' style='width: 50px;' name='tenant[business][phone_number_attributes][phone1]' maxlength='3' id='tenant_business_phone_number_attributes_phone1'> <input type='tel' style='width: 50px;' name='tenant[business][phone_number_attributes][phone2]' maxlength='4' id='tenant_business_phone_number_attributes_phone2'></li>".html_safe
        business.form_buffers.last << "<li id='tenant_phone_number_area_code_input' class='string input required stringish'><label for='tenant_phone_number_area_code' class=' label'>Phone Number</label><input type='text' style='width: 50px;' name='tenant[phone_number][area_code]' maxlength='3' id='tenant_phone_number_area_code'> <input type='text' style='width: 50px;' name='tenant[phone_number][phone1]' id='tenant_phone_number_phone1'> <input type='text' style='width: 50px;' name='tenant[phone_number][phone2]' id='tenant_phone_number_phone2'></li>".html_safe
      end
    end

    f.inputs "Address Details", :for => [:address, f.object.businesses.first.address] do |address|
      address.input :street
      address.input :suite
      address.input :city
      address.input :zip_code
      address.input :state, as: :select, collection: US_STATES.collect {|p| [ p.last, p.first ] },prompt: 'Select State/Province'
      address.input :country, as: :select, collection: COUNTRIES.collect {|p| [ p.last, p.first ] },prompt: 'Select Country'
      #address.time_zone_select :timezone, ActiveSupport::TimeZone.us_zones,{:default => 'Pacific Time (US & Canada)'}
    end

    f.actions
  end

  controller do
    skip_before_filter :decide_redirection
    autocomplete :tenant, :subdomain
    def new
      ActsAsTenant.current_tenant = nil
      @tenant = Tenant.new(status:'active')
      @tenant.build_owner
      business = @tenant.businesses.build
      business.build_address
      #business.build_phone_number
    end

    def create
      ActsAsTenant.current_tenant = nil
      #tenant_params = params[:tenant]
      user_params = params[:tenant].delete(:owner_attributes)
      business_params = params[:tenant].delete(:business)
      address_params = params[:tenant].delete(:address)
      phone_number_params = params[:tenant].delete(:phone_number)
      @tenant = Tenant.new(status:'active')
      @tenant.attributes = params[:tenant]
      if @tenant.invalid? #|| user.password_match?
        user = @tenant.build_owner(user_params)
        business = @tenant.businesses.build(business_params)
        address = business.build_address(address_params)
        address.valid?; business.valid?; user.valid?; user.password_match?
        render :action => :new and return
      end
      result = true
      @tenant.transaction do
        begin
          @tenant.from_admin = true
          @tenant.save!#(validate: false)
          ActsAsTenant.with_tenant(@tenant) do
            user = @tenant.build_owner(user_params)
            user.subdomain, user.status = @tenant.subdomain, @tenant.status
            business = @tenant.businesses.build(business_params)
            address = business.build_address(address_params)
            unless user.password_match?
              address.valid?; business.valid?; @tenant.valid?; user.valid?; user.password_match?
              render :action => :new and return
            end
            phone_number = PhoneNumber.new(phone_number_params)
            user.skip_confirmation!
            user.save!
            business.save!
            address.locatable = business
            address.timezone = @tenant.timezone
            address.save!
            phone_number.callable = business
            if phone_number.valid?
              phone_number.save!
            end
            user.reset_authentication_token!
            calendar = Calendar.new(name: 'General', color: '#757779', apt_length: '30', business_id: business.id, calendar_auth_token: SecureRandom.hex)
            calendar.timezone = @tenant.timezone
            calendar.calendar_hours.build
            calendar.calendar_hours.first.hours_type = "hours"
            calendar.calendar_hours.first.week_days = ["MON","TUE","WED","THU","FRI"]
            calendar.calendar_hours.first.start_time = "9:00am"
            calendar.calendar_hours.first.close_time = "5:00pm"
            calendar.calendar_hours << CalendarHour.new(hours_type: "windows", week_days: ["MON","TUE","WED","THU","FRI"], start_time: "9:00am", close_time: "5:00pm")
            calendar.save!
          end
        rescue => e
          result = false
          raise ActiveRecord::Rollback
        end
      end
      if result
        redirect_to tenants_path
      else
        render :action => :new
      end
    end
    # def index_new
    #   @tenants = Tenant.search_tenant(params[:search])
    # end

  end
end
