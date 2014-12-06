module BraintreeApi
  extend self

  PRORATE_ADD_ON = 'one_time_add_on'
  VOICEMAIL_ADD_ON = 'voicemail'
  PHONE_MENU_ADD_ON = 'phone_menu'
  CALL_RECORD_ADD_ON = 'call_record'
  ADD_ON_PRICE = 10.0
  SCRIPT_CALL_ADD_ON = 'script_calls'
  MENU_CALL_ADD_ON = 'menu_calls'
  MAIL_CALL_ADD_ON = 'voicemail_calls'
  ONE_TIME_DISCOUNT = 'one_time'

  #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/6t7mx6
  #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/9r7f2m
  def find_subscription(id)
    Braintree::Subscription.find(id)
  end

  def insert_call_charges(subscription_id, script_calls, menu_calls, mail_calls)
    update_add_ons = {add: [], update: []}
    subscription = find_subscription(subscription_id)
    add_ons = subscription.add_ons
    result = {start_date: subscription.billing_period_start_date, end_date: subscription.billing_period_end_date,
              billing_cycle: subscription.current_billing_cycle, show_on: subscription.billing_period_end_date.to_date + 1}
    ####  P H O N E  S C R I P T  ############################################################
    if script_calls > 0
      index = add_ons.map(&:id).index(SCRIPT_CALL_ADD_ON)
      if index
        current_add_on = add_ons[index]
        if current_add_on.number_of_billing_cycles == current_add_on.instance_variable_get('@current_billing_cycle')
          # update amount and number_of_billing_cycles + 1
          update_add_ons[:update] << {existing_id: SCRIPT_CALL_ADD_ON, amount: script_calls,
                                      number_of_billing_cycles: current_add_on.number_of_billing_cycles+1}
        elsif current_add_on.number_of_billing_cycles > current_add_on.instance_variable_get('@current_billing_cycle')
          # new amount + old amount
          update_add_ons[:update] << {existing_id: SCRIPT_CALL_ADD_ON, amount: current_add_on.amount + script_calls}
        end
      else
        update_add_ons[:add] << {inherited_from_id: SCRIPT_CALL_ADD_ON, amount: script_calls}
      end
    end
    ####  P H O N E  M E N U  ############################################################
    if menu_calls > 0
      index = add_ons.map(&:id).index(MENU_CALL_ADD_ON)
      if index
        current_add_on = add_ons[index]
        if current_add_on.number_of_billing_cycles == current_add_on.instance_variable_get('@current_billing_cycle')
          # update amount and number_of_billing_cycles + 1
          update_add_ons[:update] << {existing_id: MENU_CALL_ADD_ON, amount: menu_calls,
                                      number_of_billing_cycles: current_add_on.number_of_billing_cycles+1}
        elsif current_add_on.number_of_billing_cycles > current_add_on.instance_variable_get('@current_billing_cycle')
          # new amount + old amount
          update_add_ons[:update] << {existing_id: MENU_CALL_ADD_ON, amount: current_add_on.amount + menu_calls}
        end
      else
        update_add_ons[:add] << {inherited_from_id: MENU_CALL_ADD_ON, amount: menu_calls}
      end
    end
    ####  V O I C E M A I L  ############################################################
    if mail_calls > 0
      index = add_ons.map(&:id).index(MAIL_CALL_ADD_ON)
      if index
        current_add_on = add_ons[index]
        if current_add_on.number_of_billing_cycles == current_add_on.instance_variable_get('@current_billing_cycle')
          # update amount and number_of_billing_cycles + 1
          update_add_ons[:update] << {existing_id: MAIL_CALL_ADD_ON, amount: mail_calls,
                                      number_of_billing_cycles: current_add_on.number_of_billing_cycles+1}
        elsif current_add_on.number_of_billing_cycles > current_add_on.instance_variable_get('@current_billing_cycle')
          # new amount + old amount
          update_add_ons[:update] << {existing_id: MAIL_CALL_ADD_ON, amount: current_add_on.amount + mail_calls}
        end
      else
        update_add_ons[:add] << {inherited_from_id: MAIL_CALL_ADD_ON, amount: mail_calls}
      end
    end
    puts "update_add_ons ==> #{update_add_ons.inspect}"
    #result.merge!(success: false)
    #update_add_ons
    from_bt = Braintree::Subscription.update(subscription_id, add_ons: update_add_ons)
    if from_bt.success?
      result.merge!(success: from_bt.success?)
    else
      puts "====ERROR MESSAGE: #{from_bt.message} ==="
      result.merge!(success: from_bt.success?, error: from_bt.message)
    end
  end

  def insert_add_on_amount(subscription_id, add_on_id)
    #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/2ybmhr
    update_add_ons = {add: [], update: []}
    subscription = find_subscription(subscription_id)
    add_ons = subscription.add_ons
    index = add_ons.map(&:id).index(add_on_id)
    if index
      update_add_ons[:update] << {existing_id: add_on_id, quantity: add_ons[index].quantity+1}
    else
      update_add_ons[:add] << {inherited_from_id: add_on_id}
    end
    result = {next_month: {amount: ADD_ON_PRICE, billing_cycle: subscription.current_billing_cycle + 1,
               start_date: subscription.first_billing_date.to_date + subscription.current_billing_cycle.months,
               end_date: subscription.first_billing_date.to_date + (subscription.current_billing_cycle+1).months - 1,
               billing_cycle: subscription.current_billing_cycle + 1,
               show_on: subscription.billing_period_end_date.to_date + 1} }
    prorated_amount = proration_math(subscription)
    if prorated_amount > 0
      index = add_ons.map(&:id).index(PRORATE_ADD_ON)
      if index
        current_add_on = add_ons[index]
        if current_add_on.number_of_billing_cycles == current_add_on.instance_variable_get('@current_billing_cycle')
          # update amount and number_of_billing_cycles + 1
          update_add_ons[:update] << {existing_id: PRORATE_ADD_ON, amount: prorated_amount,
                                      number_of_billing_cycles: current_add_on.number_of_billing_cycles+1}
        elsif current_add_on.number_of_billing_cycles > current_add_on.instance_variable_get('@current_billing_cycle')
          # new amount + old amount
          update_add_ons[:update] << {existing_id: PRORATE_ADD_ON, amount: current_add_on.amount + prorated_amount}
        end
      else
        update_add_ons[:add] << {inherited_from_id: PRORATE_ADD_ON, amount: prorated_amount}
      end
      result.merge!(prorated: {amount: prorated_amount, start_date: Date.today,
                               end_date: subscription.billing_period_end_date,
                               billing_cycle: subscription.current_billing_cycle + 1,
                               show_on: subscription.billing_period_end_date.to_date + 1} )
    end
    puts "update_add_ons ==> #{update_add_ons.inspect}"
    #result.merge!(success: false)
    from_bt = Braintree::Subscription.update(subscription_id, add_ons: update_add_ons)
    if from_bt.success?
      result.merge!(success: from_bt.success?)
    else
      puts "====ERROR MESSAGE: #{from_bt.message} ==="
      result.merge!(success: from_bt.success?, error: from_bt.message)
    end
  end

  def remove_add_on_amount(subscription_id, add_on_id)
    subscription = find_subscription(subscription_id)
    add_ons = subscription.add_ons
    index = add_ons.map(&:id).index(add_on_id)
    if index
      update_add_ons = {remove: [], update: []}
      if add_ons[index].quantity > 1
        update_add_ons[:update] << {existing_id: add_on_id, quantity: add_ons[index].quantity-1}
      else
        update_add_ons[:remove] << add_on_id
      end
      puts "UPDATE_ADD_ONS ==> #{update_add_ons.inspect}"
      result = {deleted_at: Time.now.utc}
      from_bt = Braintree::Subscription.update(subscription_id, add_ons: update_add_ons)
      if from_bt.success?
        result.merge!(success: from_bt.success?)
      else
        puts "====ERROR MESSAGE: #{from_bt.message} ==="
        result.merge!(success: from_bt.success?, error: from_bt.message)
      end
    else
      result = {success: false}
    end
    result
  end

  def proration_math(subscription)
    total_days = (subscription.billing_period_end_date.to_date - subscription.billing_period_start_date.to_date).to_f + 1
    days_left = (subscription.billing_period_end_date.to_date - Date.today).to_i
    (ADD_ON_PRICE * (days_left/total_days)).round(2) # prorated_amount
  end

  #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/6k4zg2
  #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/jsqtb2
  def subscribe_add_on(customer_id, days, prorated_amount)
    #https://sandbox.braintreegateway.com/merchants/cwdkg8vsfr7x7cb7/subscriptions/6sv33r
    Braintree::Subscription.create(
        payment_method_token: payment_token(customer_id),
        plan_id: PackageConfig::ADD_ON_SERVICE,
        trial_period: true,
        trial_duration: days,
        trial_duration_unit: 'day',
        :add_ons => {  # prorated amount as add-on for next billing
            :add => [
                {
                    :inherited_from_id => "one_time_add_on",
                    :amount => BigDecimal.new(prorated_amount.to_s)
                }
            ]
        }
    )
  end

  def subscribe_plan(customer_id, days, plan_id)
    Braintree::Subscription.create(
        payment_method_token: payment_token(customer_id),
        plan_id: plan_id,
        trial_period: true,
        trial_duration: days,
        trial_duration_unit: 'day'
    )
  end

  # give credit to users
  def update_subscription_discount(subscription_id, discount_amount)
    #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/ds69cr
    update_add_ons = {add: [], update: []}
    subscription = find_subscription(subscription_id)
    discounts = subscription.discounts
    index = discounts.map(&:id).index(ONE_TIME_DISCOUNT)
    result = {start_date: subscription.billing_period_start_date, end_date: subscription.billing_period_end_date, balance: subscription.balance,
              billing_cycle: subscription.current_billing_cycle, show_on: subscription.billing_period_end_date.to_date + 1}
    if index
      current_discount = discounts[index]
      update_add_ons[:update] << {existing_id: ONE_TIME_DISCOUNT, amount: current_discount.amount + discount_amount}
    else
      update_add_ons[:add] << {inherited_from_id: ONE_TIME_DISCOUNT, amount: discount_amount}
    end
    from_bt = Braintree::Subscription.update(subscription_id, discounts: update_add_ons)
    if from_bt.success?
      result.merge!(success: from_bt.success?)
    else
      puts "====ERROR MESSAGE: #{from_bt.message} ==="
      result.merge!(success: from_bt.success?, error: from_bt.message)
    end
  end

  def change_plan(subscription_id, plan_id)
    #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/djdv76
    #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/3xmw22
    #https://sandbox.braintreegateway.com/merchants/xghpmnxkg7skhfyg/subscriptions/bdz3r2
    Braintree::Subscription.update(subscription_id,
      :plan_id => plan_id,
      :price => PackageConfig::PLAN_PRICE[plan_id],
      :options => {
          :prorate_charges => true,
          :revert_subscription_on_proration_failure => true
      }
    )
  end

  def subscribe_discount_plan(customer_id, plan_id, plan, coupen_code_amount)
    Braintree::Subscription.create(
      payment_method_token: payment_token(customer_id),
      plan_id: plan_id,
      :discounts => {
        :add => [
          {
            :inherited_from_id => plan,
            :amount => coupen_code_amount
          }
        ]
      }
    )
  end

  def make_transaction(amount, customer_id)
    Braintree::Transaction.sale(
      amount: amount,
      payment_method_token: payment_token(customer_id),
      options: { submit_for_settlement: true }
    )
  end

  def find_customer(id)
    Braintree::Customer.find(id)
  end

  def payment_token(customer_id)
    find_customer(customer_id).credit_cards.last.token
  end

  def cancel_subscription(subscription_id)
    Braintree::Subscription.cancel(subscription_id)
  end

  def update_credit_card(customer_bid, number, exp_date, cvv, cardholder_name, address)
    Braintree::CreditCard.update(payment_token(customer_bid),
      :cardholder_name => cardholder_name,
      :cvv => cvv.to_s,
      :number => number.to_s,
      :expiration_date => exp_date.to_s,
      :options => {
        :verify_card => true
      },
      :billing_address => {
        :street_address => address['street'],
        :extended_address => address['suite'],
        :locality => address['city'],
        :region => US_STATES[address['state']] || CA_STATES[address['state']],
        :postal_code => address['zip_code'],
        :country_code_alpha2 => address['country'],
        :options => {
          :update_existing => true
        }
      }
    )
    #Braintree::Customer.update(customer_bid,
    #  :credit_card => {
    #    :cardholder_name => cardholder_name,
    #    :cvv => cvv.to_s,
    #    :number => number.to_s,
    #    :expiration_date => exp_date.to_s,
    #    :options => {
    #      :verify_card => true
    #    },
    #    :billing_address => {
    #      :street_address => "1 E Main St",
    #      :extended_address => "Suite 3",
    #      :locality => "Chicago",
    #      :region => "Illinois",
    #      :postal_code => "60622",
    #      :country_code_alpha2 => "US",
    #      :options => {
    #        :update_existing => true
    #      }
    #    }
    #  }
    #)
  end

end

#/////////////////////////////////////////////////////////////////////////////////////
#result = Braintree::Subscription.update(
#  "9r7f2m",
#  :add_ons => {
#    :add => [
#      {
#        :inherited_from_id => "service_add_on"
#      }
#    ]
#  }
#)
#
#result1 = Braintree::Subscription.update(
#  "9r7f2m",
#  :add_ons => {
#    :update => [
#      {
#        :existing_id => "service_add_on",
#        :quantity => 2
#      }
#    ]
#  }
#)
#
#result1 = Braintree::Subscription.update(
#  "9r7f2m",
#  :add_ons => {
#    :remove => ["service_add_on"]
#  }
#)
# /////////////////////////////////////////////////////////////////////////////////////

#r1= Braintree::Transaction.sale(
#          :amount => "10.00",
#          :customer_id => "66716446"
#)
#


#def refund()
#  t2=Braintree::Transaction.refund("4b4bzm", 125.00)
  # add bin to transaction table
  #[Braintree] [23/Jan/2014 08:46:31 UTC] POST /transactions/4b4bzm/refund 201
  #=> #<Braintree::SuccessfulResult transaction:#<Braintree::Transaction id: "f2km4g", type: "credit",
  #   # amount: "125.0", status: "submitted_for_settlement", created_at: 2014-01-23 08:46:31 UTC,
  #   # credit_card_details: #<token: "5ffq5g", bin: "411111", last_4: "1111", card_type: "Visa",
  #   # expiration_date: "05/2018", cardholder_name: "sadf", customer_location: "US",
  #   # prepaid: "Unknown", healthcare: "Unknown", durbin_regulated: "Unknown",
  #   # debit: "Unknown", commercial: "Unknown", payroll: "Unknown", country_of_issuance: "Unknown",
  #   # issuing_bank: "Unknown">, customer_details: #<id: "66716446", first_name: "asd", last_name: "asd",
  #   # email: "tt@dd.com", company: "asd", website: nil, phone: "123.123.123", fax: nil>,
  #   # subscription_details: #<Braintree::Transaction::SubscriptionDetails:0xce20d90 @billing_period_end_date=nil,
  #   # @billing_period_start_date=nil>, updated_at: 2014-01-23 08:46:31 UTC>>
  #
  #    t2.transaction.credit_card_details
  #=> #<token: "5ffq5g", bin: "411111", last_4: "1111", card_type: "Visa", expiration_date: "05/2018", cardholder_name: "sadf", customer_location: "US", prepaid: "Unknown", healthcare: "Unknown", durbin_regulated: "Unknown", debit: "Unknown", commercial: "Unknown", payroll: "Unknown", country_of_issuance: "Unknown", issuing_bank: "Unknown">
  #    t2.transaction.customer_details
  #=> #<id: "66716446", first_name: "asd", last_name: "asd", email: "tt@dd.com", company: "asd", website: nil, phone: "123.123.123", fax: nil>
  #
  #    t2.success?

#end
