class Subscription < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :user
  belongs_to :discount_detail
  belongs_to :subscribable, polymorphic: true
  has_many   :billing_transactions
  has_one    :add_on

  attr_accessible :subscription_bid, :customer_id, :plan, :plan_bid, :status, :price, :first_billing_date, :next_billing_date, :billing_period_start_date, :billing_period_end_date, :paid_through_date, :next_billing_period_amount, :balance, :discount_detail_id, :discount

  scope :day_before_next_due, where(billing_period_end_date: Date.today).where('plan_bid IN (?)',PackageConfig::MAIN_PLAN_IDS)

  after_update :update_status

  def new_setup(params)
  	self.status = params[:subscription_status].underscore
  	self.plan = params[:plan_name]
  	self.plan_bid = params[:plan_id]
  	self.price = BigDecimal.new(params[:subscription_price])
  	self.customer_id = params[:customer_id]
  	self.subscription_bid = params[:subscription_id]
  	self.first_billing_date = params[:first_billing_date]
  	self.next_billing_date = params[:next_billing_date]
  	self.billing_period_start_date = params[:billing_period_start_date]
  	self.billing_period_end_date = params[:billing_period_end_date]
  	self.paid_through_date = params[:paid_through_date]
  	self.next_billing_period_amount = params[:next_billing_period_amount]
  	self.balance = BigDecimal.new(params[:subscription_balance])
  	self.discount_detail_id = params[:coupon_code_id]
  	self.discount = params[:discount]
  	self
  end

  def set_plan_bid(selected_plan)
    if selected_plan == "1.5"
      self.plan_bid = "pay_as_you_go"
      self.price = BigDecimal.new("0.00")
    elsif selected_plan == "250"
      self.plan_bid = "200minutes"
      self.price = BigDecimal.new("250.00")
    elsif selected_plan == "500"
      self.plan_bid = "500minutes"
      self.price = BigDecimal.new("500.00")
    end
  end

  def active? ; status == 'active'  end

  def canceled? ;  status == 'canceled' end

  def past_due? ; status == 'past_due' || status == 'past due'  end

  def pending? ; status == 'pending'   end

  def expired? ;  status == 'expired'  end

  private ##################################

  def update_status
    if PackageConfig::MAIN_PLAN_IDS.include?(plan_bid)
      if self.subscription_bid.eql?(self.tenant.subscription_bid)
        tenant = self.tenant(true)
        if self.paid_through_date.blank?
          tenant.update_attributes(next_due: next_billing_date, plan_bid: plan_bid, status: status)
        else
          tenant.update_attributes(next_due: paid_through_date + 1, plan_bid: plan_bid, status: status)
        end
        tenant.owner.update_attributes(status: status, plan_bid: plan_bid)
      end
    elsif plan_bid.eql?(PackageConfig::ADD_ON_SERVICE)
      if self.add_on
        if self.paid_through_date.blank?
          self.add_on.update_attributes(next_due: next_billing_date, status: status,
                                        subscription_bid: subscription_bid, customer_bid: customer_id)
        else
          self.add_on.update_attributes(next_due: paid_through_date + 1, status: status,
                                        subscription_bid: subscription_bid, customer_bid: customer_id)
        end
      else
        #self.create_add_on(next_due: next_billing_date, status: status, subscription_bid: subscription_bid,
        #                   customer_bid: customer_id)
      end
    end
  end
end
