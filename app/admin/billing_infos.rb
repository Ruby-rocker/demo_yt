ActiveAdmin.register BillingInfo do
  menu :priority => 9

  actions :all, :except => [:destroy, :new, :edit]

  filter :first_name
  filter :last_name
  filter :customer_id
  filter :email
  filter :card_type
  filter :expiration_month
  filter :expiration_year
  filter :user_id

  index do
    column "Name" do |object|
    	object.first_name+" "+object.last_name rescue nil
    end
    column "Address" do |object|
  		object.address.street+", "+object.address.suite+", "+ object.address.city + ', ' + object.address.state + ' ' + object.address.zip_code rescue nil
    end
    column :customer_id
    column :email
    column :card_type
    column :expiration_month
    column :expiration_year

    default_actions
  end

  show :title => "Show Billing Info" do
  	attributes_table do
  		row :id
  		row :first_name
		  row :last_name
		  row :customer_id
		  row :email
		  row :card_type
		  row :expiration_month
		  row :expiration_year
		  row :user_id
  	end
  end
end
