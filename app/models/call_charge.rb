class CallCharge < ActiveRecord::Base
  acts_as_tenant(:tenant)
#attr_accessible :call_type

  belongs_to :tenant
  has_many   :retries, class_name: 'CallCharge', foreign_key: :retry_id
  belongs_to :first_try, class_name: 'CallCharge', foreign_key: :retry_id
  has_one    :paid_retry, class_name: 'CallCharge', foreign_key: :retry_id, conditions: {is_paid: true}

  scope :unsuccessful_payment, where("transaction_bid IS NOT NULL AND retry_id IS NULL").where(is_paid: false)
  scope :paid_retry, where(is_paid: true).where("transaction_bid IS NOT NULL AND retry_id IS NOT NULL")

  def self.unpaid_charges
    paid = paid_retry.pluck(:retry_id)
    unsuccessful_payment.where('id NOT IN (?)', paid.blank? ? 0 : paid)

    #SELECT c1.*
    #FROM call_charges c1
    #LEFT JOIN call_charges c2
    #ON c1.id = c2.retry_id AND c2.is_paid = 1
    #WHERE c1.transaction_bid IS NOT NULL
    #AND c1.is_paid = 0
    #AND c2.id IS NULL
    #AND c1.retry_id IS NULL

    #"SELECT c1.*
    #FROM call_charges c1
    #LEFT JOIN call_charges c2
    #ON c1.id = c2.retry_id
    #WHERE c1.transaction_bid IS NOT NULL AND c1.retry_id IS NULL
    #AND c1.is_paid = 0
    #AND c2.id IS NULL"
    #
    #joins("LEFT JOIN call_charges retries_call_charges ON call_charges.id = retries_call_charges.retry_id")
    #.where(call_charges: {is_paid: false}).where(retries_call_charges: {id: nil})
    #.where("call_charges.transaction_bid IS NOT NULL AND call_charges.retry_id IS NULL")
  end
end
