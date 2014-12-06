ActiveAdmin.register PhoneScript, :as => "AllPhoneScript" do
  menu :priority => 1, :label => "Phone Scripts", :parent => "AllTenant"
  actions :all, :except => [:destroy,:new, :edit, :create, :update]

  filter :tenant
  #filter :id, :label => "ViziCall Campaign ID"
  filter :name#, :label => "Campaign Name"
  filter :script_id, label: 'script type', as: :check_boxes, collection: proc { PhoneScript::SCRIPT_ID.collect { |b| [b.last, b.first] } }
  #filter :friendly_name, :label => "Twilio Number"
  filter :business#, :label => "Business Name", :collection => proc { Business.joins(:campaigns).uniq.collect {|b| [ b.buss_name, b.id ] } }
  filter :campaign_id, :label => "XPS Campaign ID"
  filter :xps_phone, :label => "XPS Phone Number"
  filter :calendar

  index do
    #column "ViziCall Campaign ID", :id
    column :id
    column :name
    column :tenant
    column :business
    column 'Script Type', :script_name
    column "Twilio Number", :twilio_number do |p|
      p.twilio_number ? p.friendly_name : nil
    end
    column "XPS Campaign ID", :campaign_id, :sortable => :campaign_id do |c|
      (c.campaign_id.blank? || c.campaign_id.nil?)? 'Not Assigned' : c.campaign_id
    end
    column "XPS Phone Number", :xps_phone, :sortable => :xps_phone do |x|
      (x.xps_phone.blank? || x.xps_phone.nil? || x.xps_phone.eql?('-1')) ? "Not Assigned" : x.xps_phone
    end

    #column :is_deleted

    default_actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :script_name
      row("XPS Campaign ID") { |c| (c.campaign_id.blank? || c.campaign_id.nil?)? 'Not Assigned' : c.campaign_id }
      row("XPS Phone Number") { |c| (c.xps_phone.blank? || c.xps_phone.nil? || c.xps_phone.eql?('-1')) ? "Not Assigned" : c.xps_phone }
      row :calendar
      row :business
      row :tenant
      row("Twilio Number") {|p| p.twilio_number ? p.friendly_name : nil}
      row :created_at
      row :updated_at
    end
  end
  controller do
    before_filter :reset_tenant
    skip_before_filter :decide_redirection
    def scoped_collection
      PhoneScript.unscoped
    end

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end

end
