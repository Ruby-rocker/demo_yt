module CallTransaction
  extend self

  # execute transaction for active users
  def execute
    puts "*********************"
    Tenant.all.each do |tenant|
      puts tenant.subdomain
      begin
        if PackageConfig::PAY_AS_YOU_GO.eql? tenant.plan_bid.to_s
          tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)

          ClientMailer.delay.call_transaction_mailer(tenant,"execute - tenant minutes - #{tenant_minutes}")

          if tenant.tenant_notification.nil?
            tenant_notification = TenantNotification.new
            tenant_notification.tenant_id = tenant.id
            tenant_notification.pay_as_you_go = 0
            tenant_notification.save
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - tenant notification created - pay as you go")
          else
            tenant_notification = tenant.tenant_notification
            tenant_notification.pay_as_you_go = 0
            tenant_notification.save
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - tenant notification updated - pay as you go")
          end

          ClientMailer.delay.call_transaction_mailer(tenant,"execute - not overage_transaction")

          if tenant_minutes > 100
            overage_transaction(tenant, "call minutes", :call_minutes, 0)
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - overage_transaction")
          end

          tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)
          if (tenant_minutes >= 90 or tenant_minutes >= 350) && !tenant_notification.pay_as_you_go.present?
            ClientMailer.delay.minutes_running_low(tenant)
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - minutes running low - pay as you go")
          end
        end

        if PackageConfig::MINUTE_200.eql? tenant.plan_bid.to_s
          if tenant.tenant_notification.nil?
            tenant_notification = TenantNotification.new
            tenant_notification.tenant_id = tenant.id
            tenant_notification.minutes200 = 0
            tenant_notification.save
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - tenant notification created - 200 minutes")
          else
            tenant_notification = tenant.tenant_notification
            tenant_notification.minutes200 = 0
            tenant_notification.save
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - tenant notification updated - 200 minutes")
          end

          tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)
          if tenant_minutes >= 350 && !tenant_notification.minutes200.present?
            ClientMailer.delay.minutes_running_low(tenant)
            ClientMailer.delay.call_transaction_mailer(tenant,"execute - minutes running low - 200 minutes")
          end
        end

        #if tenant.menu_minutes > 100
        #  overage_menu_minutes(tenant)
        #  ClientMailer.delay.call_transaction_mailer(tenant,"execute - overage_transaction - menu minutes")
        #end
        #if tenant.mail_minutes > 100
        #  overage_mail_minutes(tenant)
        #  ClientMailer.delay.call_transaction_mailer(tenant,"execute - overage_transaction - mail minutes")
        #end
      rescue => e
        puts "ERROR: #{e}"
      end

    end
  end

  def overage(tenant)
    tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)
    if PackageConfig::PAY_AS_YOU_GO.eql? tenant.plan_bid.to_s
        if tenant.tenant_notification.nil?
          tenant_notification = TenantNotification.new
          tenant_notification.tenant_id = tenant.id
          tenant_notification.pay_as_you_go = 0
          tenant_notification.save
        else
          tenant_notification = tenant.tenant_notification
          tenant_notification.pay_as_you_go = 0
          tenant_notification.save
        end

        if tenant_minutes > 0
          overage_transaction(tenant, "call minutes", :call_minutes, 0)
        end

        tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)
        if (tenant_minutes >= 90 or tenant_minutes >= 350) && !tenant_notification.pay_as_you_go.present?
          ClientMailer.delay.minutes_running_low(tenant)
          ClientMailer.delay.call_transaction_mailer(tenant,"overage - minutes running low - pay as you go")
        end

        ClientMailer.delay.call_transaction_mailer(tenant,"overage - overage_transaction - pay as you go")

    elsif PackageConfig::MINUTE_200.eql? tenant.plan_bid.to_s
        if tenant.tenant_notification.nil?
          tenant_notification = TenantNotification.new
          tenant_notification.tenant_id = tenant.id
          tenant_notification.minutes200 = 0
          tenant_notification.save
        else
          tenant_notification = tenant.tenant_notification
          tenant_notification.minutes200 = 0
          tenant_notification.save
        end
        ClientMailer.delay.call_transaction_mailer(tenant,"overage - not overage_transaction - 200 minutes")

        if (tenant_minutes - 200) > 200
          overage_transaction(tenant, "call minutes", :call_minutes, 200)
          ClientMailer.delay.call_transaction_mailer(tenant,"overage - overage_transaction - 200 minutes")
        end

        tenant_minutes = (tenant.call_minutes.to_i - tenant.credit_minutes.to_i)
        if tenant_minutes >= 350 && !tenant_notification.minutes200.present?
          ClientMailer.delay.minutes_running_low(tenant)
          ClientMailer.delay.call_transaction_mailer(tenant,"overage - minutes running low - 200 minutes")
        end
    elsif PackageConfig::MINUTE_500.eql? tenant.plan_bid.to_s
      ClientMailer.delay.call_transaction_mailer(tenant,"overage - not overage_transaction - 500 minutes")
        if (tenant_minutes - 500) > 500
          overage_transaction(tenant, "call minutes", :call_minutes, 500)
          ClientMailer.delay.call_transaction_mailer(tenant,"overage - overage_transaction - 500 minutes")
        end
    end

    if tenant.menu_minutes > 100
      overage_menu_minutes(tenant)
    end
    if tenant.mail_minutes > 100
      overage_mail_minutes(tenant)
    end
  end

  private ###############################################################################

  def overage_transaction(tenant, billable_type_text, minutes_field, package_minutes)
    amount = calculate_amount(tenant, billable_type_text, package_minutes)
    amount = amount.round(2)
    t_result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
    if t_result.success?
      braintree_transaction(t_result, amount, billable_type_text, tenant.id)
      update_minute_field(tenant, billable_type_text, minutes_field)
    else

      if PackageConfig::PAY_AS_YOU_GO.eql? tenant.plan_bid.to_s
        if tenant.call_minutes > 0
          call_minutes = tenant.call_minutes - PackageConfig::FREE_MINUTES[tenant.plan_bid]
          tenant.update_attributes(:call_minutes => call_minutes)
        end
      elsif PackageConfig::MINUTE_200.eql? tenant.plan_bid.to_s
        if tenant.call_minutes > 200
          call_minutes = tenant.call_minutes - PackageConfig::FREE_MINUTES[tenant.plan_bid]
          tenant.update_attributes(:call_minutes => call_minutes)
        end
      elsif PackageConfig::MINUTE_500.eql? tenant.plan_bid.to_s
        if tenant.call_minutes > 500
          call_minutes = tenant.call_minutes - PackageConfig::FREE_MINUTES[tenant.plan_bid]
          tenant.update_attributes(:call_minutes => call_minutes)
        end
      end
      if tenant.menu_minutes > 100
        menu_minutes = tenant.menu_minutes - PackageConfig::FREE_MINUTES['add_on_service']
        tenant.update_attributes(:menu_minutes => menu_minutes)
      end
      if tenant.mail_minutes > 100
        mail_minutes = tenant.mail_minutes - PackageConfig::FREE_MINUTES['add_on_service']
        tenant.update_attributes(:mail_minutes => mail_minutes)
      end

      next_try(tenant)
    end
    if PackageConfig::PAY_AS_YOU_GO.eql? tenant.plan_bid.to_s
      tenant.tenant_notification.update_attributes(:pay_as_you_go => 1)
      ClientMailer.delay.call_transaction_mailer(tenant,"tenant notification - update to 1 - pay as you go")
    elsif PackageConfig::MINUTE_200.eql? tenant.plan_bid.to_s
      tenant.tenant_notification.update_attributes(:minutes200 => 1)
      ClientMailer.delay.call_transaction_mailer(tenant,"tenant notification - update to 1 - minutes200")
    end
    ClientMailer.delay.call_transaction_mailer(tenant,"overage_transaction - #{amount}, #{t_result.success?}, #{tenant.plan_bid}, #{billable_type_text}, #{package_minutes}, #{minutes_field}")
  end

  def calculate_amount(tenant, billable_type_text, package_minutes)
    if billable_type_text == "call minutes"
      amount = ((tenant.call_minutes.to_i - tenant.credit_minutes.to_i) - package_minutes) * PackageConfig::OVERAGE[tenant.plan_bid]
    elsif billable_type_text == "phone menu minutes"
      amount = (tenant.menu_minutes.to_i - 100) * PackageConfig::OVERAGE['add_on_service']
    elsif billable_type_text == "voicemail minutes"
      amount = (tenant.mail_minutes.to_i - 100)* PackageConfig::OVERAGE['add_on_service']
    end
    return amount
  end

  def braintree_transaction(t_result, amount, billable_type_text, tenant_id)
    transaction = BillingTransaction.new
    transaction.transaction_bid = t_result.transaction.id
    transaction.status = t_result.transaction.status
    transaction.amount = t_result.transaction.amount
    transaction.billable_type = "#{amount} for #{billable_type_text}"
    transaction.created_on = t_result.transaction.created_at
    transaction.updated_on = t_result.transaction.updated_at
    transaction.customer_id = t_result.transaction.customer_details.id
    transaction.last_4 = t_result.transaction.credit_card_details.last_4
    transaction.tenant_id = tenant_id
    transaction.save
  end

  def update_minute_field(tenant, billable_type_text, minutes_field)
    if billable_type_text == "call minutes"
      tenant.update_attributes(minutes_field => 0, :credit_minutes => 0, :block_date => nil)
    else
      tenant.update_attributes(minutes_field => 0, :block_date => nil)
    end
  end

  def next_try(tenant)
    if tenant.block_date.present?
      if Date.today < tenant.block_date
        days = (tenant.block_date - Date.today).to_i
        billing_info = tenant.billing_info
        SubscriptionMailer.delay.payment_unsuccessful(billing_info,days)
      end
    else
      tenant.update_attributes(:block_date => Date.today + 10.days)
    end
  end

  def overage_menu_minutes(tenant)
    overage_transaction(tenant, "phone menu minutes", :menu_minutes, 0)
  end

  def overage_mail_minutes(tenant)
    overage_transaction(tenant, "voicemail minutes", :mail_minutes, 0)
  end

end