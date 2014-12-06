class CreditAmount < ActiveRecord::Base
  acts_as_tenant(:tenant)	
  attr_accessible :amount, :tenant_id
  belongs_to :tenant
  validates :amount,:numericality => {only_integer: true , :greater_than => 0, less_than: 10000}
  validate :eligibility
  after_create :credit_discount

  private ########################################################

  def eligibility
    #errors[:base] << "can not credit amount when status is #{tenant.status}" unless tenant.is_paid?
    errors.add(:amount, "can not credit amount when status is #{tenant.status}") unless tenant.is_paid?
  end

  def credit_discount
    ActsAsTenant.with_tenant(tenant) do
      result = BraintreeApi.update_subscription_discount(tenant.subscription_bid, amount)
      if result.delete(:success)
        add_on_log = AddOnLog.new(result)
        add_on_log.amount = amount * -1
        add_on_log.prorated = true # successful
        add_on_log.chargeable = self
        add_on_log.save
      else
        raise ActiveRecord::Rollback
      end
    end
  end
  handle_asynchronously :credit_discount

end
