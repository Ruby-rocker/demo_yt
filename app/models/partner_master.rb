class PartnerMaster < ActiveRecord::Base
  devise :database_authenticatable, :async, :registerable, :confirmable, :token_authenticatable,:recoverable, :rememberable, :trackable, :validatable, :timeoutable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :notes, :id, :phone_number_attributes, :address_attributes, :doc_sign, :authentication_token
  before_save :ensure_authentication_token

  has_one  :discount_master, dependent: :destroy
  has_one  :partner_payment_inormations, dependent: :destroy
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  has_one :partner_logo, dependent: :destroy
  has_one :partner_landing
  has_many :partner_stats
  has_many :commissions
  has_one   :audio_file, as: :audible, dependent: :destroy

  has_one :address, as: :locatable, dependent: :destroy
  has_one :phone_number, as: :callable, dependent: :destroy

  accepts_nested_attributes_for :address, :phone_number
  accepts_nested_attributes_for :partner_logo

  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password] << "should contain at least 8 characters and one numeric." if /^(?=.*[a-z])(?=.*\d).{8,128}$/i.match(password).nil?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    !password.blank? && /^(?=.*[a-z])(?=.*\d).{8,128}$/i.match(password).present? && password == password_confirmation
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def has_file?
    audio_file.present?
  end
end
