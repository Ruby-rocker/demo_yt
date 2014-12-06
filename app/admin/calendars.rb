ActiveAdmin.register Calendar, :as => "AdminCalendar" do
  menu false

  actions :all, :except => [:destroy, :new, :edit]

  filter :tenant_id
  filter :business_id
  filter :name
  filter :color

  index do
    column :name
    column :color
    column :timezone
    column :apt_length
    column :business_id
    default_actions
  end

  show :title => "Show Calendar" do |ad|
    attributes_table do
      row :id
      row :tenant_id
      row :name
      row :color
      row :timezone
      row :apt_length
      row :business_id
      row :created_at
      row :updated_at
    end
  end
end
