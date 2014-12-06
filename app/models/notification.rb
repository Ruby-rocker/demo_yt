class Notification < ActiveRecord::Base
  acts_as_tenant(:tenant)
  extend CustomFilter
  has_many :user_notifications, dependent: :destroy
  has_many :users, through: :user_notifications
  belongs_to :tenant
  belongs_to :notifiable, polymorphic: true
  attr_accessible :content, :is_read, :notify_on, :title, :notifiable_type
  cattr_accessor :displaying_range

  #validates :notify_on, :notifiable_type, :notifiable_id, :title, :content, presence: true
  #validates :notifiable_type, :uniqueness => {:scope => :notifiable_id}

  after_create :create_unread_notifications

  SETTING_MODELS = %w(BillingInfo PhoneMenu PhoneScriptData PhoneScript)
  OWNER_MODAL = %w(BillingInfo Business Calendar Contact PhoneMenu PhoneScriptData PhoneScript)

  scope :super_user_notifications, order('created_at DESC')
  scope :staff_notifications, where('notifiable_type NOT IN (?)',SETTING_MODELS).order('created_at DESC')
  scope :unread, ->(notification_id) { where("id NOT IN (?)", notification_id) }

  #%w(Appointment BillingInfo Business Calendar Contact PhoneMenu PhoneScriptData Recording User Voicemail)


  def is_read?
    self.user_notifications.present?
  end
  private ##################################

  def create_unread_notifications
    user_ids = case notifiable_type
                 when *SETTING_MODELS
                   tenant.super_users.pluck(:id)
                 else
                   tenant.service_users.pluck(:id)
               end
    user_ids.map {|user_id| self.user_notifications.create(user_id: user_id)}
  end

end
