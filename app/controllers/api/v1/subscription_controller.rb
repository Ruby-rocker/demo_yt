module Api
  module V1
    class SubscriptionController < ApplicationController
      respond_to :json
      skip_before_filter :logged_in, :set_defaults, :set_current_tenant

      def validate_email
        if params[:email]
          result = User.unscoped.find_by_email(params[:email]) ? false : true
        else
          result = false
        end
        render json: {success: result}
      end

      def discount_amount
        coupon = DiscountMaster.find_by_coupon_code_and_active(params[:coupon_code],1)
        if coupon
          result = {success: true, discount: coupon.as_json(only: [:id, :coupon_code, :duration])}
        else
          result = {success: false}
        end
        render json: result
      end

      def create
        data_c = [:email, :subscription_status, :subscription_id]
        data_c.each do |d|
          render json: {success: false, error: "Missing parameter: #{d}"} and return unless params[d]
        end
        result, msg = true, ''

        user = User.new.new_setup(params)
        user.from_payment = true
        tenant = Tenant.new.new_setup(params)
        billing_info = BillingInfo.new.new_setup(params)
        address = Address.new.new_setup(params)
        phone = PhoneNumber.new.new_setup(params)
        business = Business.new.new_setup(params)
        phone_business = PhoneNumber.new.new_setup_customer(params)
        address_business = Address.new.new_setup(params)
        #sign_up_new(params)
        subscription = Subscription.new.new_setup(params)
        billing_transaction = BillingTransaction.new.new_setup(params) if params[:transaction_id]

        tenant.transaction do
          begin
            tenant.save!(validate: false)
            #tenant.set_as_active
            ActsAsTenant.with_tenant(tenant) do
              user.save
              subscription.subscribable = user
              subscription.save
              if params[:transaction_id]
                billing_transaction.billable = tenant
                billing_transaction.subscription = subscription
                billing_transaction.save
              end
              billing_info.user = user
              billing_info.save
              address.locatable = billing_info
              address.save
              phone.callable = billing_info
              phone.save
              business.save
              address_business.locatable = business
              address_business.save
              phone_business.callable = business
              phone_business.save
              user.reset_authentication_token!
              calendar = Calendar.new(name: 'General', color: '#757779', apt_length: '30', business_id: business.id, calendar_auth_token: SecureRandom.hex)
              calendar.calendar_hours.build
              calendar.calendar_hours.first.hours_type = "hours"
              calendar.calendar_hours.first.week_days = ["MON","TUE","WED","THU","FRI"]
              calendar.calendar_hours.first.start_time = "9:00am"
              calendar.calendar_hours.first.close_time = "5:00pm"
              calendar.calendar_hours << CalendarHour.new(hours_type: "windows", week_days: ["MON","TUE","WED","THU","FRI"], start_time: "9:00am", close_time: "5:00pm")
              calendar.save

              # New User Created
              user.notifications.create(title: 'New User Created', notify_on: Time.now,
                                        content: "<span>The owner #{user.full_name} was added to your system. This user has been sent log-in information via email.</span>")

              # New Business Created
              business.notifications.create(title: 'New Business Created', notify_on: Time.now,
                                            content: "<span>The new business #{business.name} was created by #{user.full_name} and is now available for use.</span>")

              #if params[:addon_services].present?
              #  params[:addon_services].each do |addon_service|
              #    if addon_service.present?
              #      #sign_up_new(params)
              #      subscription = Subscription.new.new_setup(addon_service)
              #      billing_transaction = BillingTransaction.new.new_setup(addon_service)
              #
              #      subscription.subscribable = user
              #      subscription.save!
              #
              #      add_on = AddOn.new.new_setup(addon_service)
              #      add_on.subscription = subscription
              #      add_on.save!
              #
              #      billing_transaction.billable = add_on
              #      billing_transaction.subscription = subscription
              #      billing_transaction.save!
              #    end
              #  end
              #end
            end
            if params[:partner_master_id].present?
              commission = Commission.new
              commission.user_id = user.id
              commission.partner_master_id = params[:partner_master_id]
              commission.commission = 0.0
              commission.is_paid = 0
              commission.save
            end
          rescue => e
             result = false
             msg += ' ' + e.to_s
             raise ActiveRecord::Rollback
          end
        end
        if result
          #UserMailer.delay.subscription_notice(user.id,subscription.id,billing_transaction.id)
          AdminMailer.delay.subscription_notice(user.id)
          render json: {success: result, user_id: user.id, token: user.confirmation_token, tenant_id: tenant.id}
        else
          render json: {success: result, error: "#{msg}"}
        end
      end

    end
  end
end
