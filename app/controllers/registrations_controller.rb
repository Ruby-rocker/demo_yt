class RegistrationsController < ApplicationController
	before_filter :logged_in, :set_current_tenant, :set_defaults, except: [:rejoin, :process_rejoin, :check_coupen]

	def rejoin
		@user = User.find_by_id_and_authentication_token(params[:id].to_i, params[:token])
		# @user = User.find_by_authentication_token(params[:auth_token])
		@address = @user.tenant.billing_info.address
		@user.phone_number || @user.build_phone_number
		@business = @user.tenant.businesses.first
		# @billing_info.phone_number || @user.build_phone_number
		render layout: "rejoin_layout"
	end

	def process_rejoin
    @user = User.find_by_authentication_token(params[:user][:authentication_token])
    @user.reset_authentication_token!
    if @user && @user.is_owner? && @user.active_for_authentication?
      redirect_to root_path, notice: 'no rejoin'
    else
      result, msg = true, ''
      tenant = @user.tenant
      #customer = BraintreeApi.find_customer(tenant.customer_bid)
      #payment_method_token = customer.credit_cards[0].token
      credit = BraintreeApi.update_credit_card(tenant.customer_bid, params[:user][:card_number], "#{params[:user][:expiry_month]}/#{params[:user][:expiry_year]}", params[:user][:ccv], params[:user][:card_name], params[:address])
      # jeet continue only if credit returns true
      params[:subtotal] = params[:subtotal].gsub("$", "").to_i
      if params[:discount_type] == "percentage"
        discount_amount = ((params[:discount_amount].to_i * params[:subtotal])/100)
        coupon_code_amount = params[:subtotal] - discount_amount
      elsif params[:discount_type] == "amount"
        discount_amount = params[:discount_amount].to_i
        coupon_code_amount = params[:subtotal] - discount_amount
      end
      (params[:subtotal] = coupon_code_amount) if coupon_code_amount
      discount_duration = params[:duration]
      if coupon_code_amount
        if discount_duration == "every_month"
          result_sub = BraintreeApi.subscribe_discount_plan(tenant.customer_bid, params[:plan], "recurring", coupon_code_amount)
        else
          result_sub = BraintreeApi.subscribe_discount_plan(tenant.customer_bid, params[:plan], "one_time", coupon_code_amount)
        end
      else
        result_sub = BraintreeApi.subscribe_plan(tenant.customer_bid, 0, params[:plan])
      end
      trans = BraintreeApi.make_transaction(params[:subtotal].to_i, tenant.customer_bid)
      if trans.success?
        tenant.customer_bid = result_sub.subscription.transactions[0].customer_details.id
        tenant.next_due = result_sub.subscription.next_billing_date
        tenant.has_paid = result_sub.subscription.paid_through_date ? 1 : 0
        tenant.plan_bid = result_sub.subscription.plan_id
        tenant.status = result_sub.subscription.status.underscore
        tenant.save!(validate: false)
        tenant.transaction do
          begin
            ActsAsTenant.with_tenant(tenant) do
              @user.update_attributes(params[:user])
              @user.plan_bid = result_sub.subscription.plan_id
              @user.status = result_sub.subscription.status.underscore
              @user.save
              business = @user.tenant.businesses.first
              business.update_attributes(params[:business])

              subscription = Subscription.new
              subscription.subscribable = @user
              subscription.plan_bid = result_sub.subscription.plan_id
              subscription.customer_id = result_sub.subscription.transactions[0].customer_details.id
              subscription.subscription_bid = result_sub.subscription.id
              subscription.first_billing_date = result_sub.subscription.first_billing_date
              subscription.next_billing_date = result_sub.subscription.next_billing_date
              subscription.billing_period_start_date = result_sub.subscription.billing_period_start_date
              subscription.billing_period_end_date = result_sub.subscription.billing_period_end_date
              subscription.paid_through_date = result_sub.subscription.paid_through_date
              subscription.next_billing_period_amount = result_sub.subscription.next_billing_period_amount
              subscription.balance = BigDecimal.new(result_sub.subscription.balance)
              subscription.status = result_sub.subscription.status
              subscription.discount = discount_amount
              subscription.save!

              billing_transaction = BillingTransaction.new
              billing_transaction.billable = tenant
              billing_transaction.subscription = subscription
              billing_transaction.customer_id = result_sub.subscription.transactions[0].customer_details.id
              billing_transaction.transaction_bid = result_sub.subscription.transactions[0].id
              billing_transaction.subscription_bid = result_sub.subscription.id
              billing_transaction.status = result_sub.subscription.transactions[0].status
              billing_transaction.last_4 = result_sub.subscription.transactions[0].credit_card_details.last_4
              billing_transaction.amount = params[:subtotal]
              billing_transaction.billing_period_start_date = result_sub.subscription.billing_period_start_date
              billing_transaction.billing_period_end_date = result_sub.subscription.billing_period_end_date
              billing_transaction.type_of = result_sub.subscription.transactions[0].type
              billing_transaction.save!

              @user.reset_authentication_token!
            end
          rescue => e
             result = false
             msg += ' ' + e.to_s
             raise ActiveRecord::Rollback
          end
        end
        if result
          #UserMailer.delay.subscription_notice(user.id,subscription.id,billing_transaction.id)
          AdminMailer.delay.subscription_notice(@user.id)
          flash[:notice] = "Your account has been successfuly activated. You can sign in now"
          redirect_to new_user_session_path
        else
          flash[:notice] = msg
          redirect_to rejoin_registrations_path(id: @user.id)
        end
      else
        flash[:notice] = "Your transection is not successful. Please change your credit card detail or try again"
        redirect_to rejoin_registrations_path(id: @user.id)
      end
    end
	end

	def check_coupen
		coupon = DiscountMaster.find_by_coupon_code_and_active(params[:coupen_code],1)
    if coupon
      result = {success: true, discount: coupon.as_json(only: [:id, :coupon_code, :duration])}
    else
      result = {success: false}
    end
		render json: result
	end
end