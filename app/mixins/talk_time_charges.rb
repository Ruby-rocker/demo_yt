module TalkTimeCharges
  extend self

  # every day charge
  def daily_charge
    puts "===========TalkTimeCharges=======#{Time.now}======"
    Tenant.pay_as_you_go_100_min.each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        # charge for call minutes
        if tenant.call_minutes > 100
          call_flag = script_call_charge(tenant)
          manage_block_date(tenant, call_flag)
        elsif tenant.call_minutes >= 90 && tenant.tenant_notification.blank? # minutes running low mailer
          ClientMailer.delay.minutes_running_low(tenant)
          tenant.create_tenant_notification
        end
      end # ActsAsTenant.with_tenant(tenant)
    end
    Tenant.minutes_low_200_plan.each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        # minutes running low mailer
        if tenant.call_minutes >= 350 && tenant.tenant_notification.blank?
          ClientMailer.delay.minutes_running_low(tenant)
          tenant.create_tenant_notification
        end
      end # ActsAsTenant.with_tenant(tenant)
    end
    # payment of un-successful retry
  end

  # overage charge every month
  def overage_charge(tenant_id)
    tenant = Tenant.find(tenant_id)
    ActsAsTenant.with_tenant(tenant) do
      ####  V O I C E M A I L  ############################################################
      call_flag = mail_flag = menu_flag = true
      if tenant.mail_minutes > 0
        call_charge = CallCharge.new
        call_charge.next_due = tenant.next_due
        call_charge.call_type = 'Voicemail'
        call_charge.total_min = tenant.mail_minutes
        call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
        call_charge.credit_min = tenant.credit_mail_minutes
        chargeable_min = call_charge.total_min - call_charge.free_min - call_charge.credit_min
        amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
        if amount > 0
          call_charge.amount = amount
          result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
          bt_transaction = result.transaction
          # save transaction
          if bt_transaction
            call_charge.transaction_bid = bt_transaction.id
            save_transaction(bt_transaction, call_charge)
          end
          if result.success?
            tenant.mail_minutes = tenant.credit_mail_minutes = 0
            call_charge.is_paid = true
          else # failed transaction
            mail_flag = false
            tenant.mail_minutes = tenant.credit_mail_minutes = 0
            #tenant.block_date = Date.today + 10.days
          end
        else # chargeable is zero or negative
          tenant.mail_minutes = 0
        end
        call_charge.save
        tenant.save
      end ####  V O I C E M A I L  ############################################################

      ####  P H O N E  M E N U  ############################################################
      if tenant.menu_minutes > 0
        call_charge = CallCharge.new
        call_charge.next_due = tenant.next_due
        call_charge.call_type = 'PhoneMenu'
        call_charge.total_min = tenant.menu_minutes
        call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
        call_charge.credit_min = tenant.credit_menu_minutes
        chargeable_min = call_charge.total_min - call_charge.free_min - call_charge.credit_min
        amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
        if amount > 0
          call_charge.amount = amount
          result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
          bt_transaction = result.transaction
          # save transaction
          if bt_transaction
            call_charge.transaction_bid = bt_transaction.id
            save_transaction(bt_transaction, call_charge)
          end
          if result.success?
            tenant.menu_minutes = tenant.credit_menu_minutes = 0
            call_charge.is_paid = true
          else # failed transaction
            menu_flag = false
            tenant.menu_minutes = tenant.credit_menu_minutes = 0
            #tenant.block_date = Date.today + 10.days
          end
        else # chargeable is zero or negative
          tenant.menu_minutes = 0
        end
        call_charge.save
        tenant.save
      end ####  P H O N E  M E N U  ############################################################

      ####  P H O N E  S C R I P T  ############################################################
      if tenant.call_minutes > 0
        call_flag = script_call_charge(tenant, call_flag)
      end ####  P H O N E  S C R I P T  ############################################################

      ####### Add/Remove block date ############################################################
      manage_block_date(tenant, call_flag && mail_flag && menu_flag)

    end # ActsAsTenant.with_tenant(tenant)
  end

  private ###############################################################################

  def script_call_charge(tenant, call_flag=true)
    call_charge = CallCharge.new
    call_charge.next_due = tenant.next_due
    call_charge.call_type = 'PhoneScript'
    call_charge.total_min = tenant.call_minutes
    call_charge.free_min = PackageConfig::FREE_MINUTES[tenant.plan_bid]
    call_charge.credit_min = tenant.credit_minutes
    chargeable_min = call_charge.total_min - call_charge.free_min - call_charge.credit_min
    amount = (chargeable_min * PackageConfig::OVERAGE[tenant.plan_bid]).round(2)
    if amount > 0
      call_charge.amount = amount
      result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
      bt_transaction = result.transaction
      # save transaction
      if bt_transaction
        call_charge.transaction_bid = bt_transaction.id
        save_transaction(bt_transaction, call_charge)
      end
      if result.success?
        tenant.call_minutes = tenant.credit_minutes = 0
        call_charge.is_paid = true
      else # failed transaction
        tenant.call_minutes = tenant.credit_minutes = 0
        call_flag = false
        #tenant.block_date = Date.today + 10.days
      end
    else # chargeable is zero or negative
      tenant.call_minutes = 0
    end
    call_charge.save
    tenant.save
    tenant.tenant_notification.try(:destroy) # minutes running low mailer flag
    call_flag
  end

  def manage_block_date(tenant, flag)
    unpaid = tenant.call_charges.unpaid_charges.first
    if unpaid
      block_date = unpaid.created_at.to_date + 10.days
      if block_date != tenant.block_date
        tenant.block_date = block_date
        tenant.save
      end
      unless flag
        days = (tenant.block_date - Date.today).to_i
        SubscriptionMailer.delay.payment_unsuccessful(tenant.billing_info, days) if days > 0
      end
    else # no unpaid charges
      tenant.block_date = nil
      tenant.save
    end
  end

  def save_transaction(bt_transaction, call_charge)
    billing_transaction = BillingTransaction.new
    billing_transaction.transaction_bid = bt_transaction.id
    billing_transaction.type_of = bt_transaction.type
    billing_transaction.amount = bt_transaction.amount
    billing_transaction.last_4 = bt_transaction.credit_card_details.last_4
    billing_transaction.status = bt_transaction.status
    billing_transaction.customer_id = bt_transaction.customer_details.id
    billing_transaction.created_on = bt_transaction.created_at
    billing_transaction.updated_on = bt_transaction.updated_at
    billing_transaction.billable = call_charge
    billing_transaction.save
  end

end