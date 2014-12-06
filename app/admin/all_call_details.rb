ActiveAdmin.register CallDetail, :as => "AllCallDetail" do
  menu :priority => 1, :label => "Call Details",  :parent => "AllTenant"
  actions :all, :except => [:destroy,:new, :edit, :create, :update]

  index do
    column :tenant
    column :call_to
    column :call_from
    column :duration do |p|
      seconds_to_time(p.duration)
    end
    column :direction
    column :start_time
    column :end_time
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :call_sid
      row :call_to
      row :call_from
      row("Duration") { |p| seconds_to_time(p.duration) }
      row :start_time
      row :end_time
      row :call_to
      row :call_from
      row :direction
      row :from_city
      row :from_country
      row :from_state
      row :from_zip
      row :to_city
      row :to_country
      row :to_state
      row :to_zip
    end
  end
  controller do
    before_filter :reset_tenant

    skip_before_filter :decide_redirection

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end
end
