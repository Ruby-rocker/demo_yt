module Settings::BillingsHelper
  def service_item(billing_transaction)
    item_label = ''
    if !billing_transaction.billable_type.nil? && billing_transaction.billable_type.include?("Tenant")
      #tenant = Tenant.find(billing_transaction.billable_id).plan_bid
      if billing_transaction.subscription_id.present?
        subscription_plan = Subscription.find(billing_transaction.subscription_id).plan_bid
        if subscription_plan == "500minutes"
          item_label = "500 Minute Plan"
        elsif subscription_plan == "200minutes"
          item_label = "200 Minute Plan"
        else
          item_label = "Pay As You Go"
        end
      end
    elsif !billing_transaction.billable_type.nil? && billing_transaction.billable_type.include?("AddOn")
      add_on = AddOn.find(billing_transaction.billable_id).type_of
      if add_on == AddOn::TYPE_OF[2]
        item_label = "Call Recording"
      elsif add_on == AddOn::TYPE_OF[1]
        item_label = "Phone Menu"
      elsif add_on == AddOn::TYPE_OF[0]
        item_label = "Voicemail"
      end
    elsif !billing_transaction.billable_type.nil?
      item_label = billing_transaction.billable_type.to_s
    end
    return item_label
  end

  def service_name(transaction)
    case transaction.chargeable_type
      when 'Voicemail', 'PhoneMenu'
        "#{transaction.chargeable_type}(#{transaction.chargeable.name})"
      when 'CallCharge'
        "#{transaction.chargeable_type}(#{transaction.chargeable.call_type} Calls)"
      else
        transaction.chargeable_type
    end
  end

  def get_rate(transaction, plan)
    case transaction.chargeable.call_type
      when 'Voicemail', 'PhoneMenu'
        PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]
      when 'PhoneScript'
        PackageConfig::OVERAGE[plan]
    end
  end

end
