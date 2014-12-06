class DiscountMaster < ActiveRecord::Base
  belongs_to :partner_master
  attr_accessible :coupon_code, :amount, :percentage, :partner_master_id, :active, :duration, :notes, :discount_type
  attr_accessor :discount_type

  DURATION = {first_month: 'First Month', every_month: 'Every Month'}

  before_validation :set_coupon_code
  after_initialize  :set_defaults

  validates :partner_master_id, :presence => {:message => "Select partner or create one if you haven't yet."}, :uniqueness => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 9999.99 }, :allow_nil => true
  validates :percentage, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100 }, :allow_nil => true
  validates :amount, :presence => true, :if => "discount_type.eql?('1')"
  validates :percentage, :presence => true, :unless => "discount_type.eql?('1')"
  validates :coupon_code, :format => { :with => /^[a-z\d]+([- _][a-z\d]+)*$/i,
                                       :message => "is invalid (use only letters, numbers, '-', and '_')." },
                                       :length => { :in => 3..20 }, :uniqueness => true
  #validates :duration, :inclusion => { :in => %w(first_month every_month),
  #                                     :message => "%{value} is not a valid duration" }

  validates :duration, :numericality => {only_integer: true , :greater_than => 0}

  def as_json(options={})
    if amount
      super(options).merge!(:amount => format('%.2f', self.amount), :percentage => nil)
    else
      super(options).merge!(:percentage => format('%.2f', self.percentage), :amount => nil)
    end
  end

  private ###################################################

  def set_coupon_code
    self.coupon_code = coupon_code.strip if coupon_code.present?
    if discount_type == '1'
      self.percentage = nil
    else
      self.amount = nil
    end
  end

  def set_defaults
    if new_record?
      self.discount_type = discount_type || '1'
      #self.duration = duration || 'first_month'
    else
      self.discount_type = amount ? '1' : '2'
    end
  end

end
