class TenantConfig < ActiveRecord::Base
	acts_as_tenant(:tenant)
	attr_accessible :discount_minutes, :credit_for
  belongs_to :tenant

  validates :credit_for, :inclusion => { :in => %w(PhoneScript PhoneMenu Voicemail) }
  validates :discount_minutes, :presence => true
end
