class WebhooksController < ApplicationController

  skip_before_filter :logged_in, :set_defaults, :set_current_tenant

  def handle
    logger.info("$$$$$$$$$$$$$$$$$ W E B H O O K ====#{Time.now}====================")
    webhook_notification = Braintree::WebhookNotification.parse(params[:bt_signature], params[:bt_payload])
    case webhook_notification.kind
      when 'transaction_disbursed'
        transaction_status_update(webhook_notification) # transaction is settled
      else
        subscription_update(webhook_notification)
    end
    head :ok
  end

  def verify
    render text: Braintree::WebhookNotification.verify(params[:bt_challenge])
  end

  private #######################################

  def subscription_update(webhook_notification)
    wh_subscription = webhook_notification.subscription
    ClientMailer.delay.webhook(wh_subscription.status, wh_subscription.plan_id, webhook_notification.kind, wh_subscription.id)
    subscription = Subscription.unscoped.find_by_subscription_bid(wh_subscription.id)
    if subscription
      add_to_log(webhook_notification, wh_subscription.id)
      tenant = subscription.tenant
      if webhook_notification.kind.eql?('subscription_charged_successfully') && tenant.block_date.present?
        tenant.block_date = nil
        tenant.save
      elsif webhook_notification.kind.eql?('subscription_charged_unsuccessfully') && tenant.block_date.blank?
        tenant.block_date = Date.today + 10.days
        tenant.save
      end
      case webhook_notification.kind
        when 'subscription_charged_successfully'
          #if subscription.present? && subscription.tenant.present? && (!subscription.plan_bid.eql? PackageConfig::ADD_ON_SERVICE)
          #  if subscription.first_billing_date.present? && (Date.today.eql? subscription.first_billing_date)
          #    SubscriptionMailer.delay.monthly_subscription_active(subscription.tenant.billing_info)
          #  else
          #    SubscriptionMailer.delay.monthly_subscription_renewed(subscription.tenant.billing_info)
          #  end
          #end
        when 'subscription_canceled'
          # mailer
        when 'subscription_charged_unsuccessfully'
          if tenant.present?
            SubscriptionMailer.delay.monthly_subscription_unsuccessful(tenant.billing_info, tenant)
          end
      end
      old_balance = subscription.balance
      ActsAsTenant.with_tenant(tenant) do
        subscription.wh_kind = webhook_notification.kind
        subscription.wh_timestamp = webhook_notification.timestamp
        subscription.status = wh_subscription.status.try(:underscore)
        subscription.plan_bid = wh_subscription.plan_id
        subscription.price = wh_subscription.price
        subscription.first_billing_date = wh_subscription.first_billing_date
        subscription.next_billing_date = wh_subscription.next_billing_date
        subscription.billing_period_start_date = wh_subscription.billing_period_start_date
        subscription.billing_period_end_date = wh_subscription.billing_period_end_date
        subscription.paid_through_date = wh_subscription.paid_through_date
        subscription.next_billing_period_amount = wh_subscription.next_billing_period_amount
        subscription.balance = wh_subscription.balance
        subscription.billing_cycle = wh_subscription.current_billing_cycle
        subscription.save
        wh_subscription.transactions.each do |transaction|
          transaction_update(transaction, webhook_notification, subscription, old_balance)
        end

        if ['subscription_charged_successfully', 'subscription_charged_unsuccessfully'].include?(webhook_notification.kind)
          wh_transaction = wh_subscription.transactions.first
          if wh_transaction
            add_on_log = AddOnLog.where(start_date: wh_transaction.subscription_details.billing_period_start_date,
                                        end_date: wh_transaction.subscription_details.billing_period_end_date,
                                        chargeable_id: subscription.id, chargeable_type: 'Subscription').first_or_initialize
            add_on_log.prorated = webhook_notification.kind.eql?('subscription_charged_successfully')
            add_on_log.balance = subscription.balance
            add_on_log.amount = wh_transaction.amount
            add_on_log.save
          end

          add_on_log = AddOnLog.where(start_date: wh_subscription.billing_period_start_date,
                                      end_date: wh_subscription.billing_period_end_date,
                                      chargeable_id: subscription.id, chargeable_type: 'Subscription').first_or_initialize
          add_on_log.prorated = webhook_notification.kind.eql?('subscription_charged_successfully')
          add_on_log.balance = subscription.balance
          add_on_log.save

          add_ons = wh_subscription.add_ons
          index = add_ons.map(&:id).index('phone_menu')
          if index
            AddOnLog.active_phone_menus.each do |log|
              new_log = AddOnLog.new
              new_log.chargeable_id   = log.chargeable_id
              new_log.chargeable_type = log.chargeable_type
              new_log.amount          = 10
              new_log.start_date      = wh_subscription.billing_period_start_date
              new_log.end_date        = wh_subscription.billing_period_end_date
              new_log.prorated        = false
              new_log.save
            end
          end
          index = add_ons.map(&:id).index('voicemail')
          if index
            AddOnLog.active_voicemails.each do |log|
              new_log = AddOnLog.new
              new_log.chargeable_id   = log.chargeable_id
              new_log.chargeable_type = log.chargeable_type
              new_log.amount          = 10
              new_log.start_date      = wh_subscription.billing_period_start_date
              new_log.end_date        = wh_subscription.billing_period_end_date
              new_log.prorated        = false
              new_log.save
            end
          end
          index = add_ons.map(&:id).index('call_record')
          if index
            log = AddOnLog.active_call_record
            if log
              new_log = AddOnLog.new
              new_log.chargeable_type = log.chargeable_type
              new_log.amount          = 10
              new_log.start_date      = wh_subscription.billing_period_start_date
              new_log.end_date        = wh_subscription.billing_period_end_date
              new_log.prorated        = false
              new_log.save
            end
          end

          #if webhook_notification.kind.eql?('subscription_charged_successfully') && tenant.block_date.present?
          #  tenant.block_date = nil
          #  tenant.save
          #elsif webhook_notification.kind.eql?('subscription_charged_unsuccessfully') && tenant.block_date.blank?
          #  tenant.block_date = Date.today + 10.days
          #  tenant.save
          #end
        end


        #if webhook_notification.kind.eql?('subscription_canceled')
        #  #SubscriptionMailer.delay.subscription_cancelled(user.full_name, user.email)
        #elsif !webhook_notification.kind.eql?('subscription_went_active')
        #  #SubscriptionMailer.delay.subscription_status_change(subscription.status, user)
        #end
        if subscription.present? && subscription.tenant.present? && (!subscription.plan_bid.eql? PackageConfig::ADD_ON_SERVICE)
          #CallTransaction.overage(subscription.tenant)
          TalkTimeCharges.overage_charge(subscription.tenant_id)
        end

        tenant.tenant_notification.try(:destroy) # minutes running low mailer flag

      end # eof ActsAsTenant
    end  # eof if subscription
  end

  def transaction_update(wh_transaction, webhook_notification, subscription, old_balance)
    billing_transaction = BillingTransaction.find_or_initialize_by_transaction_bid(wh_transaction.id)
    if billing_transaction.new_record?
      billing_transaction.wh_timestamp = webhook_notification.timestamp
      billing_transaction.wh_kind = webhook_notification.kind
      billing_transaction.type_of = wh_transaction.type
      billing_transaction.amount = wh_transaction.amount
      billing_transaction.last_4 = wh_transaction.credit_card_details.last_4
      billing_transaction.status = wh_transaction.status
      billing_transaction.billing_cycle = subscription.billing_cycle
      billing_transaction.subscription_id = subscription.id
      billing_transaction.balance = old_balance.to_f
      billing_transaction.customer_id = wh_transaction.customer_details.id
      billing_transaction.subscription_bid = subscription.subscription_bid
      billing_transaction.created_on = wh_transaction.created_at
      billing_transaction.updated_on = wh_transaction.updated_at
      #billing_transaction.billing_period_start_date = subscription.billing_period_start_date
      #billing_transaction.billing_period_end_date = subscription.billing_period_end_date
    else
      billing_transaction.wh_timestamp = webhook_notification.timestamp
      billing_transaction.wh_kind = webhook_notification.kind
      billing_transaction.status = wh_transaction.status
    end
    billing_transaction.billing_period_start_date = wh_transaction.subscription_details.billing_period_start_date
    billing_transaction.billing_period_end_date = wh_transaction.subscription_details.billing_period_end_date
    if subscription.plan_bid.eql?(PackageConfig::ADD_ON_SERVICE)
      billing_transaction.billable_type = subscription.subscribable_type
      billing_transaction.billable_id = subscription.subscribable_id
    end
    billing_transaction.save
  end

  def transaction_status_update(webhook_notification) # transaction is settled
    wh_transaction = webhook_notification.transaction
    billing_transaction = BillingTransaction.unscoped.find_by_transaction_bid(wh_transaction.id)
    if billing_transaction
      billing_transaction.wh_timestamp = webhook_notification.timestamp
      billing_transaction.wh_kind = webhook_notification.kind
      billing_transaction.status = wh_transaction.status
      if wh_transaction.subscription_details
        billing_transaction.billing_period_start_date = wh_transaction.subscription_details.billing_period_start_date
        billing_transaction.billing_period_end_date = wh_transaction.subscription_details.billing_period_end_date
      end
      billing_transaction.save

      if billing_transaction.subscription.present? && billing_transaction.subscription.tenant.present? && (!billing_transaction.subscription.plan_bid.eql? PackageConfig::ADD_ON_SERVICE)
        if billing_transaction.subscription.first_billing_date.present? && (Date.today.eql? billing_transaction.subscription.first_billing_date)
          SubscriptionMailer.delay.monthly_subscription_active(billing_transaction.subscription.tenant.billing_info)
        else
          SubscriptionMailer.delay.monthly_subscription_renewed(billing_transaction.subscription.tenant.billing_info)
        end
      end

    end
  end

  def add_to_log(webhook_notification, subscription_id)
    f = File.open("log/webhook_log.log",'a')
    f.puts("************ W E B H O O K == START=======#{Time.now}==============")
    f.puts("======WH KIND => #{webhook_notification.kind} ===")
    f.puts("======WH TIMESTAMP => #{webhook_notification.timestamp} ===")
    f.puts("======WH SUBSCRIPTION ID => #{subscription_id} ===")
    f.puts("************************E N D*************************************************")
    f.close
  end
end
