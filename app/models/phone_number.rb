class PhoneNumber < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :callable, polymorphic: true
  attr_protected :tenant_id

  validates :tenant_id, :callable_type, :area_code, :phone1, :phone2, presence: true, :if => :partner_callable_type
  validates :callable_id, uniqueness: {scope: [:area_code, :callable_type, :phone1, :phone2, :name]}

  after_create :send_mailer

  def new_setup(params)
  	self.area_code = params[:billing_phone1]
  	self.phone1 = params[:billing_phone2]
  	self.phone2 = params[:billing_phone3]
  	self
  end

  def new_setup_customer(params)
    self.area_code = params[:customer_phone1]
    self.phone1 = params[:customer_phone2]
    self.phone2 = params[:customer_phone3]
    self
  end

  def print_number
    "(#{area_code}) #{phone1}-#{phone2}"
  end

  def call_number
    "+1#{area_code}#{phone1}#{phone2}"
  end

  def partner_callable_type
    return false if callable_type == 'PartnerMaster'
  end

  private

  def send_mailer
    if name.eql?('notify') && callable_type.eql?('PhoneScript')
      phone_script = PhoneScript.find(callable_id)
      ClientMailer.delay.sms_added_to_script(phone_script, self.tenant.owner.email)
    end
  end
end