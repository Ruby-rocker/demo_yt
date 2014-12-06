class PartnerPaymentInformation < ActiveRecord::Base
	belongs_to :partner_master
  attr_accessible :partner_master_id, :paypal_email, :ssn, :payment_type
end
