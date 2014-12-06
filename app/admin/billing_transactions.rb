ActiveAdmin.register BillingTransaction do
  menu :priority => 10

  actions :all, :except => [:destroy, :new, :edit]

  filter :billable_type
  filter :type_of
  
  index do
    column "Created on" do |object|
    	object.created_on.strftime('%B %d, %Y') rescue nil
    end
    column "Status" do |object|
    	if object.subscription_id && object.subscription_id.present?
        object.subscription.status
      else
        "active"
      end
    end
    column "Amount" do |object|
    	"$" + object.amount.to_s rescue nil
    end
    default_actions
  end

  show :title => "Show Billing Transaction" do |bt|
  	attributes_table do
  		row :id
  		row "Service item" do
  			service_item(bt) rescue nil
  		end
  		row "Date Range" do
  			if bt.billing_period_start_date && bt.billing_period_end_date && bt.billing_period_start_date.present? && bt.billing_period_end_date.present?
          bt.billing_period_start_date.strftime("%-m/%-d/%y") + "-" + bt.billing_period_end_date.strftime("%-m/%-d/%y")
        else
          "-"
        end
  		end
  		row "Unit Price" do
  			if bt.billable_type && bt.billable_type.include?("Tenant")
          "$ " + (@subscription.price).to_s
        else
          "$ " + bt.amount.to_s rescue nil
        end
  		end

  		row "Total Due" do
  			if bt.billable_type && bt.billable_type.include?("Tenant")
          "$ " + (@subscription.price).to_s
        else
          "$ " + bt.amount.to_s rescue nil
        end
  		end
  	end
  end

  controller do
    def show
      @subscription = Subscription.find_by_tenant_id(current_tenant.id)
    end
  end
end
