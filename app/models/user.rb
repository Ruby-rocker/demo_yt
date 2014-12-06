class User < ActiveRecord::Base
  acts_as_tenant(:tenant)

  devise :database_authenticatable, :async, :registerable, :confirmable, :token_authenticatable,:recoverable, :rememberable, :trackable, :validatable, :timeoutable
    extend CustomFilter
   cattr_accessor :displaying_range
   scope :super_user_notifications, order('created_at DESC')
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :subdomain, :role, :full_name, :status, :plan_bid
  attr_accessible :company
  attr_accessible :confirmation_token, only: :update
  attr_accessible :coupen_code, :card_type, :card_number, :ccv, :card_name, :expiry_month, :expiry_year, :selected_plan, :billing_info_attributes, :phone_number

  attr_accessor :coupen_code, :card_type, :card_number, :ccv, :card_name, :expiry_month, :expiry_year, :selected_plan

  attr_accessor :from_payment, :company, :phone
  attr_writer :limit

  def limit
    @limit || 10
  end

  OWNER = 1
  ADMIN = 2
  STAFF = 3
  CALL_CENTER = 4

  ROLE = {OWNER => 'owner', ADMIN => 'an administrator', STAFF => 'a staff/user', CALL_CENTER => 'call center'}
  USER_LIST = {'Administrator' => 2, 'User' => 3}
  scope :owner, where(role: OWNER)
  scope :admin, where(role: ADMIN)
  scope :staff, where(role: STAFF)
  scope :call_center, where(role: CALL_CENTER)
  scope :service_users, where('role in (?)', [OWNER, ADMIN, STAFF])
  scope :super_users, where('role in (?)', [OWNER, ADMIN])

  def role?(name)
    role.eql? User.const_get(name.upcase)
  rescue NameError
    false
  end

  def is_owner?
    role.eql? OWNER
  end

  def is_staff?
    role.eql? STAFF
  end

  def is_super_user?
    role.eql?(ADMIN) || role.eql?(OWNER)
  end

  def is_service_user?
    !role.eql?(CALL_CENTER)
  end

  def role_name
    case role
      when OWNER
        'Owner'
      when ADMIN
        'Admin'
      when STAFF
        'Staff'
      when CALL_CENTER
        'Call Center'
    end
  end

  before_validation :downcase_subdomain
  validates :first_name, :last_name, presence: true
  validates :role, inclusion: { in: [ OWNER, ADMIN, STAFF, CALL_CENTER ] }

  # single admin per subscription
  validates :subdomain, presence: {:message => "Business Name can't be blank." }, unless: "from_payment"
  validates :subdomain, length: { in: 3..20, :message => "Business Name length should be 3 to 20 characters)" }, unless: "from_payment"
  validate :verify_subdomain, unless: "from_payment"

  belongs_to :tenant
  has_many :contacts, dependent: :destroy
  has_many :billing_transactions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :notifications, as: :notifiable
  has_many :user_notifications, order: 'created_at DESC', include: :notification, dependent: :destroy
  has_many :unread_messages, through: :user_notifications, source: :notification
  has_one :billing_info
  has_one    :phone_number, as: :callable, dependent: :destroy
  delegate :notifications_id, to: :user_notifications

  accepts_nested_attributes_for :billing_info

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

  def full_name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def subscription_status
    tenant.try(:status)
  end

  def demo_user
    tenant.try(:from_admin)
  end

  def is_inactive?
    tenant.try(:status).eql?('canceled')
  end

  def active_for_authentication?
    if demo_user
      super
    #elsif self.is_inactive?
    #  false
    else
      super && (self.tenant.next_due + 10.days) >= Date.today # i.e. super && self.is_active
    end
  end

  def inactive_message
    if self.confirmed?
      'Sorry, this account has been deactivated.'
    else
      'You have to confirm your account before continuing.'
    end
  end

  def new_setup(params)
    self.first_name = params[:first_name]
    self.role = OWNER
    self.email = params[:email]
    self.last_name = params[:last_name]
    self.status = params[:subscription_status].underscore
    self.plan_bid = params[:plan_id]
    self.company = params[:company]
    self
  end

  # WILL BE RUN ONCE
  #def after_database_authentication
  #  puts "**** 1 ======= ONLY FOR ONCE ================="
  #  puts "******** 2 ======= ONLY FOR ONCE ================="
  #  puts "************** 3 ======= ONLY FOR ONCE ================="
  #end

  def read_true
    self.notifications_id.map{|m| m.notification_id}
  end

private ##################################

  def downcase_subdomain
    self.subdomain = subdomain.strip.downcase if subdomain
  end

  def remove_space_subdomain
    self.subdomain = subdomain.gsub(/\s+/, '') if subdomainsu t
  end

  def verify_subdomain
    sub1 = %w(www portal admin account administrator blog dashboard admindashboard assets assets1 assets2 assets3 assets4 assets5 images img files videos help support cname test cache)
    sub2 = %w(api api1 api2 api3 js css static mail ftp webmail webdisk ns ns1 ns2 ns3 ns4 ns5 register pop pop3 beta stage http https donate store payment payments smtp)
    sub3 = %w(ad admanager ads adsense adwords about abuse affiliate affiliates shop client clients code community buy cpanel whm dev developer developers docs email whois)
    sub4 = %w(signup gettingstarted home invoice invoices ios ipad iphone log logs my status network networks new newsite news partner partners partnerpage popular wiki)
    sub5 = %w(redirect random public registration resolver rss sandbox search server servers service signin signup sitemap sitenews sites sms sorry ssl staging development stagingaccount stagingpartner stagingadmin)
    sub6 = %w(stats statistics graph graphs survey surveys talk trac git svn translate upload uploads video validation validations email webmaster ww wwww www1 www2 feeds)
    sub7 = %w(secure demo i img img1 img2 img3 css1 css2 css3 js js1 js2 vizicall vizicall-staging webcal yestrak yestrak-staging stagingadmin stagingpartner staging-admin staging-partner)

    subdomains = sub1 + sub2 + sub3 + sub4 + sub5 + sub6 + sub7
    errors.add(:subdomain, "Business Name is invalid") if subdomains.include?(subdomain)
    errors.add(:subdomain, "Business Name is invalid(use only letters, numbers, '-', and '_')") unless subdomain =~ /^[a-z\d]+([-_][a-z\d]+)*$/i
  end
end
