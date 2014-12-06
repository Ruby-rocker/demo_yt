class BillingTransaction < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :billable, polymorphic: true
  belongs_to :subscription
  belongs_to :user
  attr_accessible :customer_id, :status, :transaction_bid, :subscription_bid, :status, :last_4, :amount, :created_on, :updated_on, :billing_period_start_date, :billing_period_end_date, :type_of

  scope :search_by_bt_ids, lambda { |s_bid, t_bid| where(subscription_bid: s_bid, transaction_bid: t_bid) }

  def new_setup(params)
    self.customer_id = params[:customer_id]
    self.transaction_bid = params[:transaction_id]
    self.subscription_bid = params[:subscription_id]
    self.status = params[:transaction_status]
    self.last_4 = params[:last_4]
    self.amount = BigDecimal.new(params[:transaction_amount])
    self.created_on = params[:created_at].to_datetime
    self.updated_on = params[:updated_at].to_datetime
    self.billing_period_start_date = params[:billing_period_start_date]
    self.billing_period_end_date = params[:billing_period_end_date]
    self.type_of = params[:transaction_type]
    self
  end

  def show_status
    case status
      when 'submitted_for_settlement', 'settled', 'settling'
        'PAID'
      when 'authorized'
        'PENDING'
      when 'processor_declined', 'gateway_rejected'
        'PAST DUE'
      else
        'PAST DUE'
    end
  end

  def is_paid?
    case status
      when 'submitted_for_settlement', 'settled', 'settling'
        true
      else
        false
    end
  end

  def card_number
    #510510******5100
    "************#{last_4}"
  end

  def self.initialize_by_bids(s_bid, t_bid)
    transaction = search_by_bt_ids(s_bid, t_bid).first
    new(subscription_bid: s_bid, transaction_bid: t_bid) unless transaction
  end

end