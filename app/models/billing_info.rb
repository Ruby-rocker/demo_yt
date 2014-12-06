class BillingInfo < ActiveRecord::Base
  acts_as_tenant(:tenant)

  attr_protected :tenant_id

  belongs_to :tenant
  belongs_to :user
  has_one    :address, as: :locatable, dependent: :destroy
  has_one    :phone_number, as: :callable, dependent: :destroy
  has_many :notifications, as: :notifiable
  #attr_accessible :card_type, :cardholder_name, :customer_id, :email, :expiration_month, :expiration_year, :first_name, :last_4, :last_name

  accepts_nested_attributes_for :address, :phone_number

  def card_number
    #510510******5100
    "#{bin}******#{last_4}"
  end

  def new_setup(params)
  	self.first_name = params[:billing_first_name]
  	self.last_name = params[:billing_last_name]
    self.customer_id = params[:customer_id]
  	self.email = params[:billing_email]
  	self.last_4 = params[:last_4]
  	self
  end
end

#TODO
#braintree js