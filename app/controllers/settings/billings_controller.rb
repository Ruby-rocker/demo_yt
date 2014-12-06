module Settings
  class BillingsController < ApplicationController

    before_filter :check_active, only: :upgrade_downgrade
    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @billing_info = BillingInfo.includes(:address).all
      @billing_transactions = BillingTransaction.order('created_on DESC').limit(4)
      @business = Business.first
      @tenant = current_tenant
    end

    def edit
      @billing_info = BillingInfo.find(params[:id])
      #@billing_info = current_tenant.billing_info
      if @billing_info.last_4.present?
        @billing_info.last_4 = "xxxx-xxxx-xxxx-" + @billing_info.last_4
      end
      @billing_info.phone_number || @billing_info.build_phone_number
      @billing_info.address || @billing_info.build_address
      add_breadcrumb "Billing Overview", settings_billings_path
    end

    def update
      @billing_info = BillingInfo.find(params[:billing_info][:id])
      if params[:us_state].present?
        params[:billing_info][:address_attributes][:state] = params[:us_state]
      elsif params[:ca_state].present?
        params[:billing_info][:address_attributes][:state] = params[:ca_state]
      elsif params[:other_state].present?
        params[:billing_info][:address_attributes][:state] = params[:other_state]
      end

      #raise params[:billing_info][:address_attributes][:state].inspect
      if params[:last_4].present?
        credit_card = params[:last_4]
        params[:billing_info][:last_4] = credit_card[-4,4]
        params[:billing_info][:bin] = credit_card[0,6]
        if current_tenant.from_admin?
          if @billing_info.update_attributes(params[:billing_info])
            SubscriptionMailer.delay.billing_info_modified(@billing_info)

            @billing_info.notifications.create(title: 'You have edited your billing information', notify_on: Time.now,
                                               content: "<span>#{current_user.full_name} has updated your billing information. If you do not recognize these changes, please contact Customer Care immediately.</span>")
            redirect_to settings_billings_path, notice: "Billing Information saved successfully"
          else
            flash[:alert] = 'Invalid Billing Information'
            render :edit
          end
        else
          result = BraintreeApi.update_credit_card(current_tenant.customer_bid, params[:last_4], "#{params[:billing_info][:expiration_month]}/#{params[:billing_info][:expiration_year]}", params[:ccv], params[:billing_info][:cardholder_name], params[:billing_info][:address_attributes])
          if result.success?
            SubscriptionMailer.delay.billing_info_modified(@billing_info)
            @billing_info.update_attributes(params[:billing_info])
            @billing_info.notifications.create(title: 'You have edited your billing information', notify_on: Time.now,
                                               content: "<span>#{current_user.full_name} has updated your billing information. If you do not recognize these changes, please contact Customer Care immediately.</span>")
            redirect_to settings_billings_path, notice: "Billing Information saved successfully"
          else
            flash[:alert] = 'Invalid Billing Information'
            render :edit
          end
        end
      else # if params[:last_4].present?
        if @billing_info.update_attributes(params[:billing_info])
          SubscriptionMailer.delay.billing_info_modified(@billing_info)

          @billing_info.notifications.create(title: 'You have edited your billing information', notify_on: Time.now,
                                             content: "<span>#{current_user.full_name} has updated your billing information. If you do not recognize these changes, please contact Customer Care immediately.</span>")
          redirect_to settings_billings_path, notice: "Billing Information saved successfully"
        else
          flash[:alert] = 'Invalid Billing Information'
          render :edit
        end
      end
    end

    def upgrade_downgrade
      @tenant = current_tenant
      if request.method.eql?('GET')
        render partial: "upgrade_downgrade"
      else
        old_plan = @tenant.plan_bid
        unless params[:tenant][:plan_bid].eql?(old_plan)
          result = BraintreeApi.change_plan(@tenant.subscription_bid, params[:tenant][:plan_bid])
          if result.success?
            new_subscription = result.subscription
            transaction = result.subscription.transactions.first
            subscription = Subscription.find_by_subscription_bid(new_subscription.id)
            if subscription
              subscription.status = new_subscription.status.underscore
              subscription.plan_bid = new_subscription.plan_id
              subscription.price = new_subscription.price
              subscription.subscription_bid = new_subscription.id
              subscription.first_billing_date = new_subscription.first_billing_date
              subscription.next_billing_date = new_subscription.next_billing_date
              subscription.billing_period_start_date = new_subscription.billing_period_start_date
              subscription.billing_period_end_date = new_subscription.billing_period_end_date
              subscription.paid_through_date = new_subscription.paid_through_date
              subscription.next_billing_period_amount = new_subscription.next_billing_period_amount
              subscription.balance = new_subscription.balance
              subscription.save
            end
            new_log = SubscriptionLog.new(subscription_bid: new_subscription.id, plan_bid: new_subscription.plan_id,
                                          old_plan_bid: old_plan, balance: new_subscription.balance)
            add_on_log = new_log.add_on_logs.new
            add_on_log.balance = new_subscription.balance
            add_on_log.amount = 0
            add_on_log.start_date = Date.today
            if transaction
              billing_transaction = BillingTransaction.find_or_initialize_by_transaction_bid(transaction.id)
              if billing_transaction.new_record?
                billing_transaction.type_of = transaction.type
                billing_transaction.amount = transaction.amount
                billing_transaction.last_4 = transaction.credit_card_details.last_4
                billing_transaction.status = transaction.status

                billing_transaction.subscription_id = subscription.id
                billing_transaction.customer_id = transaction.customer_details.id
                billing_transaction.subscription_bid = subscription.subscription_bid
                billing_transaction.created_on = transaction.created_at
                billing_transaction.updated_on = transaction.updated_at
                billing_transaction.billing_period_start_date = subscription.billing_period_start_date
                billing_transaction.billing_period_end_date = subscription.billing_period_end_date

                billing_transaction.billable = @tenant
                new_log.transaction_bid = transaction.id
                add_on_log.amount = billing_transaction.amount
                add_on_log.start_date = transaction.subscription_details.billing_period_start_date
                add_on_log.end_date = transaction.subscription_details.billing_period_end_date
              else
                billing_transaction.status = transaction.status
              end
              billing_transaction.save
              new_log.save
            end
            new_log.save
            add_on_log.save
            if params[:tenant][:plan_bid].to_i > old_plan.to_i
              #upgrade
              SubscriptionMailer.delay.monthly_upgrade_downgrade(@tenant.billing_info)
              Notification.create(title: 'Your Account Has Been Upgraded', notifiable_type: 'BillingInfo', notify_on: Time.now,
                content: "<span>This confirms your YesTrak Account has been upgraded to #{PackageConfig::PLAN_NAME[params[:tenant][:plan_bid]]}. You can find your monthly invoice in the settings section under 'Billing'.</span>" \
                        "<span>Thank you for your membership.</span>")
            else
              #downgrade
              SubscriptionMailer.delay.monthly_upgrade_downgrade_2(@tenant.billing_info)
              Notification.create(title: 'Your Account Has Been Downgraded', notifiable_type: 'BillingInfo', notify_on: Time.now,
                content: "<span>This confirms your YesTrak Account has been downgraded to #{PackageConfig::PLAN_NAME[params[:tenant][:plan_bid]]}. You can find your monthly invoice in the settings section under 'Billing'.</span>" \
                        "<span>Thank you for your membership.</span>")
            end

            flash[:notice] = 'Plan updated successfully.'
          else
            flash[:alert] = 'Plan is not updated.'
          end # eof if result.success?
        end
        redirect_to settings_billings_path
      end
    end

    #def upgrade_downgrade_old
    #  @tenant = current_tenant
    #  old_plan = @tenant.plan_bid
    #  logger.info("$$$$$$$$$$$$$$$$$ T E N A N T 1 ====#{@tenant.plan_bid}====================")
    #  if params[:commit].present?
    #    BraintreeApi.unsubscribe_current_plan(@tenant)
    #
    #    BraintreeApi.subscribe_new_plan(@tenant,params[:tenant][:plan_bid])
    #    SubscriptionMailer.delay.monthly_upgrade_downgrade(@tenant.billing_info)
    #    logger.info("$$$$$$$$$$$$$$$$$ T E N A N T 2 ====#{@tenant.plan_bid}====================")
    #    logger.info("$$$$$$$$$$$$$$$$$ OLD PLAN ====#{old_plan}====================")
    #    if params[:tenant][:plan_bid].to_i > (old_plan).to_i
    #      subscription = Subscription.last
    #      logger.info("$$$$$$$$$$$$$$$$$ T E N A N T 3 ====#{@tenant.plan_bid}====================")
    #      BraintreeApi.upgrade_plan(@tenant,params[:tenant][:plan_bid],subscription,old_plan)
    #      #@tenant.plan_bid = params[:tenant][:plan_bid]
    #      #@tenant.save!
    #    end
    #
    #    redirect_to settings_billings_path
    #  else
    #    render partial: "upgrade_downgrade"
    #  end
    #end

    def view_all_payments
      @billing_transactions = BillingTransaction.order('created_on DESC')
      add_breadcrumb "Billing Overview", settings_billings_path
    end

    def view_invoice
      @billing_transaction = BillingTransaction.find(params[:id])
      @transactions = AddOnLog.where('show_on BETWEEN ? AND ?', @billing_transaction.billing_period_start_date, @billing_transaction.billing_period_end_date).where('show_on IS NOT NULL')
      @subscription = @billing_transaction.subscription
      @billing_info = BillingInfo.includes(:address).all
      add_breadcrumb "Billing Overview", settings_billings_path
      add_breadcrumb "Recent Invoices", view_all_payments_settings_billings_path
    end

    def download_invoice
      #@billing_transactions = BillingTransaction.all
      @billing_transactions = BillingTransaction.order('created_on desc')
      @last_4_details = BillingTransaction.last.last_4
      @subscription = Subscription.find_by_tenant_id(current_tenant.id)
      @billing_info = BillingInfo.includes(:address).all
      @tenant_configs = TenantConfig.where(tenant_id: current_tenant.id)

      respond_to do |format|
        format.html { render layout: 'pdf'}
      end
    end

    private ###############################################

    def check_active
      if current_tenant.is_past_due? && !request.method.eql?('GET')
        flash.alert = 'You can not perform this operation when your status is past due. Update your billing info'
        redirect_to edit_settings_billing_path(current_tenant.billing_info.id)
      end
    end

  end
end
