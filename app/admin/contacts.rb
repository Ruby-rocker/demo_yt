ActiveAdmin.register Contact, :as => "AdminContact" do
  menu false

  actions :all, :except => [:destroy, :new, :edit]

  filter :first_name
  filter :last_name
  filter :status_label_id
  filter :user_id
  filter :via_xps

  index do
    column :first_name
    column :last_name
    column :status_label_id
    column :user_id
    column :via_xps
    default_actions
  end

  show :title => "Show Contact" do |ad|
    attributes_table do
      row :id
      row :tenant_id
      row :first_name
      row :last_name
      row :status_label_id
      row :user_id
      row :via_xps
      row :created_at
      row :updated_at
    end
  end
end
