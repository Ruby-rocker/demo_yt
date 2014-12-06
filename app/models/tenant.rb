class Tenant < ActiveRecord::Base
  has_many :users
  has_many :twilio_numbers
  has_many :feedbacks
  has_one  :billing_info
  has_many  :tenant_configs
  has_one  :record_call, class_name: 'AddOn', conditions: {type_of: 'CallRecord'}
  has_many  :add_ons
  has_many :subscriptions
  has_one  :current_subscription, class_name: 'Subscription', primary_key: 'subscription_bid', foreign_key: 'subscription_bid'
  has_many :billing_transactions
  has_many :call_details, dependent: :destroy
  has_many :recordings, dependent: :destroy
  has_many :notifications, as: :notifiable
  has_many :businesses
  has_many :calendars
  has_many :phone_menus
  has_many :phone_scripts
  has_many :voicemails
  has_many :call_charges
  #has_many :credit_amounts
  has_many :add_on_logs
  has_many :record_call_logs, class_name: 'AddOnLog', conditions: {chargeable_type: 'CallRecord'}
  has_one  :owner, class_name: 'User', conditions: {role: User::OWNER}
  has_one :tenant_notification

  delegate :admin, :staff, :service_users, :super_users, :to => :users
  delegate :overage, :free_minutes, :plan_price, :monthly_fee, :to => :package_config

  attr_accessible :subdomain, :call_minutes, :customer_bid, :has_paid, :subscription_bid, :next_due,
                  :timezone, :status, :plan_bid, :credit_minutes, :block_date, :menu_minutes, :mail_minutes

  attr_accessor :from_payment
  accepts_nested_attributes_for :owner

  before_validation :downcase_subdomain
  validates :subdomain, uniqueness: { message: 'Subdomain has already been taken' }, unless: "from_payment"
  validates :subdomain, presence: {:message => "Subdomain can't be blank." }, unless: "from_payment"
  validates :subdomain, length: { in: 3..20, :message => "Subdomain length should be 3 to 20 characters)" }, unless: "from_payment"
  validate :verify_subdomain, unless: "from_payment"

  scope :active_tenants_only, -> { where(status: 'active') }
  scope :confirmed, where('subdomain IS NOT NULL').order('subdomain')
  scope :pay_as_you_go_100_min, where("plan_bid = ? AND call_minutes >= 90", PackageConfig::PAY_AS_YOU_GO).where(from_admin: false)
  scope :minutes_low_200_plan, where("plan_bid = ? AND call_minutes >= 350", PackageConfig::MINUTE_200).where(from_admin: false)
  scope :day_before_next_due, where('next_due = ?', Date.today+1)

  def new_setup(params)
    self.customer_bid = params[:customer_id]
    self.subscription_bid = params[:subscription_id]
    self.next_due = params[:next_billing_date]
    self.has_paid = params[:paid_through_date] ? 1 : 0
    self.plan_bid = params[:plan_id]
    self.status = params[:subscription_status].underscore
    self
  end

  def set_as_active
    ActsAsTenant.current_tenant = self
  end

  def is_active?
    subdomain.present? && owner.confirmed?
  end

  def title
    if is_inactive?
      "* #{subdomain} - #{owner.try(:full_name)}"
    else
      "#{subdomain} - #{owner.try(:full_name)}"
    end
  end

  def self.find_using_subdomain(domain)
    where("lower(subdomain) = ?", domain.downcase).first
  end

  def is_inactive?
    status.eql?('canceled')
  end

  def is_past_due?
    status.eql?('past due')
  end

  def is_paid?
    status.eql?('active')
  end

  #todo overage transaction
  def process_cancellation

    self.phone_scripts.each do |phone_script|
      phone_script.soft_delete
    end
    self.phone_menus.each do |phone_menu|
      phone_menu.soft_delete
    end
    self.voicemails.each do |voicemail|
      voicemail.soft_delete
    end
    CallChargesConfigure.immediate_charge(self)
    BraintreeApi.cancel_subscription(subscription_bid)
    # cancel all transactions
    #self.subscriptions.each do |s|
    #  result = BraintreeApi.cancel_subscription(s.subscription_bid)
    #  if result.success?
    #    self.status = result.subscription.status.underscore
    #    self.save
    #  end
    #end

    # calculate overage minutes
    #if self.call_minutes.to_i > self.plan_bid.to_i
    #  minutes_to_charge = self.call_minutes.to_i - self.plan_bid.to_i
    #  amount = minutes_to_charge * PackageConfig::OVERAGE[self.plan_bid]
    #
    #  # do entry in transaction table
    #  t_result = BraintreeApi.make_transaction(amount, self.customer_bid)
    #  if t_result.success?
    #    transaction = BillingTransaction.new
    #    transaction.transaction_bid = t_result.transaction.id
    #    transaction.tenant_id = self.id
    #    transaction.status = t_result.transaction.status
    #    transaction.amount = t_result.transaction.amount
    #    transaction.billable = self
    #    transaction.created_on = t_result.transaction.created_at
    #    transaction.updated_on = t_result.transaction.updated_at
    #    transaction.customer_id = t_result.transaction.customer_details.id
    #    transaction.last_4 = t_result.transaction.credit_card_details.last_4
    #    transaction.save
    #    self.update_attributes(:call_minutes => self.plan_bid.to_i)
    #    return true
    #  else
    #    return false
    #  end
    #end
    return true
  end

  private ##################################

  def package_config
    @config ||= PackageConfig.new(self.plan_bid)
  end

  def verify_subdomain
    sub1 = %w(www portal admin account administrator blog dashboard admindashboard assets assets1 assets2 assets3 assets4 assets5 images img files videos help support cname test cache)
    sub2 = %w(api api1 api2 api3 js css static mail ftp webmail webdisk ns ns1 ns2 ns3 ns4 ns5 register pop pop3 beta stage http https donate store payment payments smtp)
    sub3 = %w(ad admanager ads adsense adwords about abuse affiliate affiliates shop client clients code community buy cpanel whm dev developer developers docs email whois)
    sub4 = %w(signup gettingstarted home invoice invoices ios ipad iphone log logs my status network networks new newsite news partner partners partnerpage popular wiki)
    sub5 = %w(redirect random public registration resolver rss sandbox search server servers service signin signup sitemap sitenews sites sms sorry ssl development)
    sub6 = %w(stats statistics graph graphs survey surveys talk trac git svn translate upload uploads video validation validations email webmaster ww wwww www1 www2 feeds)
    sub7 = %w(secure demo i img img1 img2 img3 css1 css2 css3 js js1 js2 vizicall vizicall-staging webcal yestrak yestrak-staging stagingadmin stagingpartner staging-admin staging-partner)

    subdomains = sub1 + sub2 + sub3 + sub4 + sub5 + sub6 + sub7
    errors.add(:subdomain, "Subdomain is invalid") if subdomains.include?(subdomain)
    errors.add(:subdomain, "Subdomain is invalid(use only letters, numbers, '-', and '_')") unless subdomain =~ /^[a-z\d]+([-_][a-z\d]+)*$/i
  end

  private ##################################

  def downcase_subdomain
    self.subdomain = subdomain.strip.downcase if subdomain
  end

end

