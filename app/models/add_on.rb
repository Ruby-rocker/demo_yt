class AddOn < ActiveRecord::Base
  acts_as_tenant(:tenant)

  CALL_RECORD = 'CallRecord'
  VOICEMAIL = 'Voicemail'
  PHONE_MENU = 'PhoneMenu'

  belongs_to :tenant
  belongs_to :subscription

  ADD_ON_PRICE = PackageConfig::PLAN_PRICE[PackageConfig::ADD_ON_SERVICE]

  scope :call_recording, where(type_of: CALL_RECORD).where("status = 'active' OR status = 'pending'")
  scope :active_call_recording, where(type_of: CALL_RECORD).where("status = 'active'")
  scope :free_voicemail, where(type_of: VOICEMAIL).where(type_id: nil, status: 'active')
  scope :free_phone_menu, where(type_of: PHONE_MENU).where(type_id: nil, status: 'active')


  attr_accessible :subscription_bid, :customer_bid, :type_of, :status, :next_due
  #attr_accessor  :active

  TYPE_OF = [CALL_RECORD, VOICEMAIL, PHONE_MENU]

  validates :type_of, inclusion: { in: TYPE_OF }

  def is_active?
    status.eql?("active")
  end

  def new_setup(params)
    self.subscription_bid = params[:subscription_id]
    self.customer_bid = params[:customer_id]
    self.type_of = params[:addon]
    self.status = params[:subscription_status].underscore
    self.next_due = params[:next_billing_date]
    self
  end

  def call_record_add_on
    self.type_of = CALL_RECORD
    if tenant.from_admin
      if AddOn.call_recording.blank?
        self.status = 'active'
        self.save
        ClientMailer.delay.call_recordings_subscribed(self)
        Notification.create(title: 'You have subscribed to call recording', notifiable_type: 'Recording', notify_on: Time.now,
          content: "<span>Call recording was added to your system by #{self.tenant.owner.full_name}. You will be charged $10/month for this service.</span>")
      else
        ClientMailer.delay.call_recordings_subscription_canceled(self.updated_at, self.tenant.timezone, self.tenant.owner.email)
        Notification.create(title: 'You have unsubscribed from call recording', notifiable_type: 'Recording', notify_on: Time.now,
          content: "<span>#{self.tenant.owner.full_name} has unsubscribed from call recording for your system. You will no longer be charged for this service.</span>")
        self.destroy
      end
    else #===
      if AddOn.call_recording.blank?
        days, amount = proration_math
        logger.info("------#{amount.to_f}------call_record_add_on")
        add_on_subscription(days, amount)
        #if amount.zero?
        #  add_on_subscription(days)
        #elsif partial_transaction(amount)
        #  add_on_subscription(days)
        #end
        ClientMailer.delay.call_recordings_subscribed(self)
        Notification.create(title: 'You have subscribed to call recording', notifiable_type: 'Recording', notify_on: Time.now,
          content: "<span>Call recording was added to your system by #{self.tenant.owner.full_name}. You will be charged $10/month for this service.</span>")
      else # cancel subscription
        add_on_cancellation
        ClientMailer.delay.call_recordings_subscription_canceled(self)
        Notification.create(title: 'You have unsubscribed from call recording', notifiable_type: 'Recording', notify_on: Time.now,
          content: "<span>#{self.tenant.owner.full_name} has unsubscribed from call recording for your system. You will no longer be charged for this service.</span>")
      end
    end
  end

  def voicemail_phone_menu_add_on
    days, amount = proration_math
    logger.info("------#{amount.to_f}------call_record_add_on")
    add_on_subscription(days, amount)
    #if amount.zero?
    #  add_on_subscription(days)
    #elsif partial_transaction(amount)
    #  add_on_subscription(days)
    #end
  end

  def add_on_cancellation
    logger.info('---------add_on_cancellation')
    result = BraintreeApi.cancel_subscription(subscription_bid)
    if result.success?
      self.status = result.subscription.status.underscore
      self.save
    else
      false
    end
  end

  private ##################################

  def add_on_subscription(days, amount)
    result = BraintreeApi.subscribe_add_on(tenant.customer_bid, days, amount)
    if result.success?
      subscription = Subscription.new
      self.subscription_bid = subscription.subscription_bid = result.subscription.id
      self.status = subscription.status = result.subscription.status.underscore
      self.next_due = subscription.next_billing_date = result.subscription.next_billing_date
      subscription.plan_bid = result.subscription.plan_id
      subscription.customer_id = tenant.customer_bid
      self.customer_bid = subscription.customer_id
      subscription.subscribable_type = self.type_of
      subscription.subscribable_id = self.type_id
      subscription.save
      self.subscription_id = subscription.id
      self.save
    else
      false
    end
  end

  def partial_transaction(amount)
    t_result = BraintreeApi.make_transaction(amount, tenant.customer_bid)
    if t_result.success?
      transaction = BillingTransaction.new
      transaction.transaction_bid = t_result.transaction.id
      transaction.status = t_result.transaction.status
      transaction.amount = t_result.transaction.amount
      transaction.billable = self
      transaction.type_of = t_result.transaction.type
      transaction.created_on = t_result.transaction.created_at
      transaction.updated_on = t_result.transaction.updated_at
      transaction.customer_id = t_result.transaction.customer_details.id
      transaction.last_4 = t_result.transaction.credit_card_details.last_4
      transaction.save
    else
      false
    end
  end

  def proration_math
    plan_detail = tenant.current_subscription
    total_days = (plan_detail.billing_period_end_date - plan_detail.billing_period_start_date).to_f + 1
    days_left = (plan_detail.billing_period_end_date - Date.today).to_i
    prorated_amount = (ADD_ON_PRICE * (days_left/total_days)).round(2)
    [days_left+1, prorated_amount] # trial period and amount
  end

end
