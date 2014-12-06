class Business < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  attr_protected :tenant_id

  belongs_to :tenant
  has_many   :calendars
  has_one   :address, as: :locatable, dependent: :destroy
  has_one   :phone_number, as: :callable, dependent: :destroy
  has_many  :phone_scripts
  has_many  :voicemails
  has_many  :phone_menus
  has_many :notifications, as: :notifiable

  scope :with_zip_code, lambda { |zip_code| joins(:address).where(addresses: {zip_code: zip_code}) }

  delegate :call_number, :print_number, to: :phone_number

  after_save :xps_insert_business

  accepts_nested_attributes_for :address, :phone_number

  validates :name, presence: true
  validates :name, uniqueness: {scope: :tenant_id}

  def new_setup(params)
    self.name = params[:company]
    self
  end

  def name_number
    "#{name} #{print_number}"
  end

private ##################################

  def xps_insert_business
    # update xps api
    phone_scripts.each do |phone_script|
      CallCenter::XpsUsa.insert_business(phone_script.id, tenant.subdomain)
    end
  end
end