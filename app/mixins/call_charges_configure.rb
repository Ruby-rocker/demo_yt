module CallChargesConfigure
  extend self

  # every day charge pay_as_you_go plan
  def daily_charge
    puts "===========TalkTimeCharges=======#{Time.now}======"
    Tenant.pay_as_you_go_100_min.each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        if tenant.call_minutes >= 90 && tenant.tenant_notification.blank? # minutes running low mailer
          ClientMailer.delay.minutes_running_low(tenant)
          tenant.create_tenant_notification
        end
        # charge for call minutes
        if tenant.call_minutes > 100
          ############################################################
          current_subscription = tenant.current_subscription
          ############################################################
          add_on_log = AddOnLog.new
          add_on_log.balance = current_subscription.balance
          add_on_log.show_on = current_subscription.billing_period_end_date + 1
          call_charge = CallCharge.new
          call_charge.next_due = Date.today
          call_charge.call_type = 'PhoneScript'
          call_charge.total_min = tenant.call_minutes
          call_charge.retry_id = 0
          call_charge.free_min = PackageConfig::FREE_MINUTES[tenant.plan_bid]
          chargeable_min = call_charge.total_min - call_charge.free_min #- call_charge.credit_min
          call_charge.credit_min = tenant.credit_minutes
          if chargeable_min <= tenant.credit_minutes
            tenant.credit_minutes = tenant.credit_minutes - chargeable_min
          else
            tenant.credit_minutes = 0
          end
          chargeable_min = chargeable_min - call_charge.credit_min
          amount = (chargeable_min * PackageConfig::OVERAGE[tenant.plan_bid]).round(2)
          if amount > 0
            add_on_log.amount = call_charge.amount = amount
            if current_subscription.balance >= 0
              # transaction full amount start ######################
              save_transaction(amount,tenant, call_charge)
              # transaction full amount end ######################
            else # if current_subscription.balance >= 0
              diff = amount + current_subscription.balance
              if diff > 0
                save_transaction(diff,tenant, call_charge)# transaction diff amount
                # add on current_subscription.balance.abs
                result = BraintreeApi.insert_call_charges(tenant.subscription_bid, current_subscription.balance.abs, 0, 0)
                call_charge.is_paid = true if result[:success]
                current_subscription.balance = 0
              else
                # no transaction
                # add on amount
                result = BraintreeApi.insert_call_charges(tenant.subscription_bid, amount, 0, 0)
                call_charge.is_paid = true if result[:success]
                tenant.call_minutes = 0
                current_subscription.balance = diff
              end
              current_subscription.save
            end
          else # chargeable is zero or negative
            tenant.call_minutes = 0
          end
          call_charge.save
          tenant.save
          add_on_log.chargeable = call_charge
          add_on_log.prorated = true
          add_on_log.end_date = Date.today
          add_on_log.save
          ############################################################
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

  def save_transaction(amount, tenant, call_charge)
    # transaction full amount start ######################
    result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
    bt_transaction = result.transaction
    # save transaction
    if bt_transaction
      call_charge.transaction_bid = bt_transaction.id
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
    if result.success?
      tenant.call_minutes = 0
      call_charge.is_paid = true
      tenant.block_date = nil
    else # failed transaction
      tenant.call_minutes = 0
      call_charge.is_paid = false
      tenant.block_date = Date.today + 10.days if tenant.block_date.blank?
    end
    # transaction full amount end ######################
  end

  # overage charge every month
  def overage_charge
    Subscription.unscoped.day_before_next_due.each do |subscription|
      tenant = subscription.tenant
      if tenant.present?
        ActsAsTenant.with_tenant(tenant) do
          mail_log = menu_log = script_log = false
          ####  V O I C E M A I L  ############################################################
          if tenant.mail_minutes > 0
            mail_call_charge = CallCharge.new
            mail_call_charge.next_due = Date.today
            mail_call_charge.call_type = 'Voicemail'
            mail_call_charge.total_min = tenant.mail_minutes
            mail_call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
            mail_call_charge.retry_id = 0
            mail_log = AddOnLog.new
            chargeable_min = mail_call_charge.total_min - mail_call_charge.free_min #- mail_call_charge.credit_min
            mail_call_charge.credit_min = tenant.credit_mail_minutes
            if chargeable_min <= tenant.credit_mail_minutes
              tenant.credit_mail_minutes = tenant.credit_mail_minutes - chargeable_min
            else
              tenant.credit_mail_minutes = 0
            end
            chargeable_min = chargeable_min - mail_call_charge.credit_min
            amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
            mail_log.amount = amount
            mail_log.chargeable = mail_call_charge
            if amount > 0
              mail_call_charge.amount = amount
              tenant.mail_minutes = 0
              mail_call_charge.is_paid = true
            else # chargeable is zero or negative
              mail_log.amount = 0
              tenant.mail_minutes = 0
            end # if amount > 0
            mail_call_charge.save
            #tenant.save
          end ####  V O I C E M A I L  ############################################################

          ####  P H O N E  M E N U  ############################################################
          if tenant.menu_minutes > 0
            menu_call_charge = CallCharge.new
            menu_call_charge.next_due = Date.today
            menu_call_charge.call_type = 'PhoneMenu'
            menu_call_charge.total_min = tenant.menu_minutes
            menu_call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
            menu_call_charge.retry_id = 0
            menu_log = AddOnLog.new
            chargeable_min = menu_call_charge.total_min - menu_call_charge.free_min #- menu_call_charge.credit_min
            menu_call_charge.credit_min = tenant.credit_menu_minutes
            if chargeable_min <= tenant.credit_menu_minutes
              tenant.credit_menu_minutes = tenant.credit_menu_minutes - chargeable_min
            else
              tenant.credit_menu_minutes = 0
            end
            chargeable_min = chargeable_min - menu_call_charge.credit_min
            amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
            menu_log.amount = amount
            menu_log.chargeable = menu_call_charge
            if amount > 0
              menu_call_charge.amount = amount
              tenant.menu_minutes = 0
              menu_call_charge.is_paid = true
            else # chargeable is zero or negative
              menu_log.amount = 0
              tenant.menu_minutes = 0
            end
            menu_call_charge.save
            #tenant.save
          end ####  P H O N E  M E N U  ############################################################

          ####  P H O N E  S C R I P T  ############################################################
          if tenant.call_minutes > 0
            script_call_charge = CallCharge.new
            script_call_charge.next_due = Date.today
            script_call_charge.call_type = 'PhoneScript'
            script_call_charge.total_min = tenant.call_minutes
            script_call_charge.free_min = PackageConfig::FREE_MINUTES[tenant.plan_bid]
            script_call_charge.credit_min = tenant.credit_minutes
            script_call_charge.retry_id = 0
            script_log = AddOnLog.new
            chargeable_min = script_call_charge.total_min - script_call_charge.free_min #- script_call_charge.credit_min
            script_call_charge.credit_min = tenant.credit_minutes
            if chargeable_min <= tenant.credit_minutes
              tenant.credit_minutes = tenant.credit_minutes - chargeable_min
            else
              tenant.credit_minutes = 0
            end
            chargeable_min = chargeable_min - script_call_charge.credit_min
            amount = (chargeable_min * PackageConfig::OVERAGE[tenant.plan_bid]).round(2)
            script_log.amount = amount
            script_log.chargeable = script_call_charge
            if amount > 0
              script_call_charge.amount = amount
              tenant.call_minutes = 0
              script_call_charge.is_paid = true
            else # chargeable is zero or negative
              script_log.amount = 0
              tenant.call_minutes = 0
            end
            script_call_charge.save
          end ####  P H O N E  S C R I P T  ############################################################
          mail_amount = menu_amount = script_amount = 0
          tenant.save
          if mail_log
            mail_amount = mail_log.amount
          end
          if menu_log
            menu_amount = menu_log.amount
          end
          if script_log
            script_amount = script_log.amount
          end
          result = BraintreeApi.insert_call_charges(tenant.subscription_bid, script_amount, menu_amount, mail_amount)
          if result[:success]
            if mail_log
              mail_log.start_date = result[:start_date]
              mail_log.end_date = result[:end_date]
              mail_log.show_on = result[:show_on]
              mail_log.billing_cycle = result[:billing_cycle]
              mail_log.save
            end
            if menu_log
              menu_log.start_date = result[:start_date]
              menu_log.end_date = result[:end_date]
              menu_log.show_on = result[:show_on]
              menu_log.billing_cycle = result[:billing_cycle]
              menu_log.save
            end
            if script_log
              script_log.start_date = result[:start_date]
              script_log.end_date = result[:end_date]
              script_log.show_on = result[:show_on]
              script_log.billing_cycle = result[:billing_cycle]
              script_log.save
            end
          else # result[:success]
            if mail_log
              mail_log.deleted_at = Time.now
              mail_log.save
            end
            if menu_log
              menu_log.deleted_at = Time.now
              menu_log.save
            end
            if script_log
              script_log.deleted_at = Time.now
              script_log.save
            end
          end
        end # ActsAsTenant.with_tenant(tenant) do
      end # if tenant.present?
    end
  end

  def immediate_transaction(amount, tenant, call_charge)
    result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
    bt_transaction = result.transaction
    # save transaction
    if bt_transaction
      call_charge.transaction_bid = bt_transaction.id
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
    if result.success?
      #tenant.call_minutes = 0
      call_charge.is_paid = true
      tenant.block_date = nil
    else # failed transaction
      #tenant.call_minutes = 0
      call_charge.is_paid = false
      puts "==========#{result.message}==="
      tenant.block_date = Date.today + 10.days if tenant.block_date.blank?
    end
    return result.success?
  end

  # on cancellation
  def immediate_charge(tenant)
    #tenant = subscription.tenant
    if tenant.present?
      subscription = tenant.current_subscription
      ActsAsTenant.with_tenant(tenant) do
        #mail_log = menu_log = script_log = false
        ####  V O I C E M A I L  ############################################################
        if tenant.mail_minutes > 0
          mail_call_charge = CallCharge.new
          mail_call_charge.next_due = Date.today
          mail_call_charge.call_type = 'Voicemail'
          mail_call_charge.total_min = tenant.mail_minutes
          mail_call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
          mail_call_charge.retry_id = 0
          mail_log = AddOnLog.new
          chargeable_min = mail_call_charge.total_min - mail_call_charge.free_min #- mail_call_charge.credit_min
          mail_call_charge.credit_min = tenant.credit_mail_minutes
          if chargeable_min <= tenant.credit_mail_minutes
            tenant.credit_mail_minutes = tenant.credit_mail_minutes - chargeable_min
          else
            tenant.credit_mail_minutes = 0
          end
          chargeable_min = chargeable_min - mail_call_charge.credit_min
          amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
          mail_log.amount = amount
          mail_log.chargeable = mail_call_charge
          if amount > 0
            mail_call_charge.amount = amount
            tenant.mail_minutes = 0
            mail_call_charge.is_paid = true
          else # chargeable is zero or negative
            mail_log.amount = 0
            tenant.mail_minutes = 0
          end # if amount > 0
          mail_log.start_date = subscription.billing_period_start_date
          mail_log.end_date = subscription.billing_period_end_date
          mail_log.show_on = subscription.billing_period_end_date
          mail_log.billing_cycle = subscription.billing_cycle
          if mail_log.amount > 0
            unless immediate_transaction(mail_log.amount, tenant, mail_call_charge)
              mail_log.deleted_at = Time.now
            end
          end
          mail_call_charge.save
          mail_log.save
        end ####  V O I C E M A I L  ############################################################

        ####  P H O N E  M E N U  ############################################################
        if tenant.menu_minutes > 0
          menu_call_charge = CallCharge.new
          menu_call_charge.next_due = Date.today
          menu_call_charge.call_type = 'PhoneMenu'
          menu_call_charge.total_min = tenant.menu_minutes
          menu_call_charge.free_min = PackageConfig::FREE_MINUTES[PackageConfig::ADD_ON_SERVICE]
          menu_call_charge.retry_id = 0
          menu_log = AddOnLog.new
          chargeable_min = menu_call_charge.total_min - menu_call_charge.free_min #- menu_call_charge.credit_min
          menu_call_charge.credit_min = tenant.credit_menu_minutes
          if chargeable_min <= tenant.credit_menu_minutes
            tenant.credit_menu_minutes = tenant.credit_menu_minutes - chargeable_min
          else
            tenant.credit_menu_minutes = 0
          end
          chargeable_min = chargeable_min - menu_call_charge.credit_min
          amount = (chargeable_min * PackageConfig::OVERAGE[PackageConfig::ADD_ON_SERVICE]).round(2)
          menu_log.amount = amount
          menu_log.chargeable = menu_call_charge
          if amount > 0
            menu_call_charge.amount = amount
            tenant.menu_minutes = 0
            menu_call_charge.is_paid = true
          else # chargeable is zero or negative
            menu_log.amount = 0
            tenant.menu_minutes = 0
          end
          menu_log.start_date = subscription.billing_period_start_date
          menu_log.end_date = subscription.billing_period_end_date
          menu_log.show_on = subscription.billing_period_end_date
          menu_log.billing_cycle = subscription.billing_cycle
          if menu_log.amount > 0
            unless immediate_transaction(menu_log.amount, tenant, menu_call_charge)
              menu_log.deleted_at = Time.now
            end
          end
          menu_call_charge.save
          menu_log.save
          #tenant.save
        end ####  P H O N E  M E N U  ############################################################

        ####  P H O N E  S C R I P T  ############################################################
        if tenant.call_minutes > 0
          script_call_charge = CallCharge.new
          script_call_charge.next_due = Date.today
          script_call_charge.call_type = 'PhoneScript'
          script_call_charge.total_min = tenant.call_minutes
          script_call_charge.free_min = PackageConfig::FREE_MINUTES[tenant.plan_bid]
          script_call_charge.credit_min = tenant.credit_minutes
          script_call_charge.retry_id = 0
          script_log = AddOnLog.new
          chargeable_min = script_call_charge.total_min - script_call_charge.free_min #- script_call_charge.credit_min
          script_call_charge.credit_min = tenant.credit_minutes
          if chargeable_min <= tenant.credit_minutes
            tenant.credit_minutes = tenant.credit_minutes - chargeable_min
          else
            tenant.credit_minutes = 0
          end
          chargeable_min = chargeable_min - script_call_charge.credit_min
          amount = (chargeable_min * PackageConfig::OVERAGE[tenant.plan_bid]).round(2)
          script_log.amount = amount
          script_log.chargeable = script_call_charge
          if amount > 0
            script_call_charge.amount = amount
            tenant.call_minutes = 0
            script_call_charge.is_paid = true
          else # chargeable is zero or negative
            script_log.amount = 0
            tenant.call_minutes = 0
          end
          script_log.start_date = subscription.billing_period_start_date
          script_log.end_date = subscription.billing_period_end_date
          script_log.show_on = subscription.billing_period_end_date
          script_log.billing_cycle = subscription.billing_cycle
          if script_log.amount > 0
            unless immediate_transaction(script_log.amount, tenant, script_call_charge)
              script_log.deleted_at = Time.now
            end
          end
          script_call_charge.save
          script_log.save
        end ####  P H O N E  S C R I P T  ############################################################
        tenant.save

        #mail_amount = menu_amount = script_amount = 0
        #tenant.save
        #if mail_log
        #  mail_amount = mail_log.amount
        #end
        #if menu_log
        #  menu_amount = menu_log.amount
        #end
        #if script_log
        #  script_amount = script_log.amount
        #end
        #
        #
        #result = BraintreeApi.insert_call_charges(tenant.subscription_bid, script_amount, menu_amount, mail_amount)
        #if result[:success]
        #  if mail_log
        #    mail_log.start_date = subscription.billing_period_start_date
        #    mail_log.end_date = subscription.billing_period_end_date
        #    mail_log.show_on = subscription.billing_period_end_date
        #    mail_log.billing_cycle = subscription.billing_cycle
        #    mail_log.save
        #  end
        #  if menu_log
        #    menu_log.start_date = subscription.billing_period_start_date
        #    menu_log.end_date = subscription.billing_period_end_date
        #    menu_log.show_on = subscription.billing_period_end_date
        #    menu_log.billing_cycle = subscription.billing_cycle
        #    menu_log.save
        #  end
        #  if script_log
        #    script_log.start_date = subscription.billing_period_start_date
        #    script_log.end_date = subscription.billing_period_end_date
        #    script_log.show_on = subscription.billing_period_end_date
        #    script_log.billing_cycle = subscription.billing_cycle
        #    script_log.save
        #  end
        #else # result[:success]
        #  if mail_log
        #    mail_log.deleted_at = Time.now
        #    mail_log.save
        #  end
        #  if menu_log
        #    menu_log.deleted_at = Time.now
        #    menu_log.save
        #  end
        #  if script_log
        #    script_log.deleted_at = Time.now
        #    script_log.save
        #  end
        #end

      end # ActsAsTenant.with_tenant(tenant) do
    end # if tenant.present?
  end
  handle_asynchronously :immediate_charge

end

