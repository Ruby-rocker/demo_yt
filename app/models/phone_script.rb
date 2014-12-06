class PhoneScript < ActiveRecord::Base
  acts_as_tenant(:tenant)

  SCRIPT_ID = {'take_msg' => 'Take a message', 'book_apt' => 'Book an appointment',
                 'gather_info' => 'Gather information'}

  FREE_SCRIPT = 2

  SCRIPT_NO = {'take_msg'=> 1, 'book_apt'=> 2, 'gather_info'=> 3}

  scope :live, where('campaign_id IS NOT NULL AND xps_phone IS NOT NULL AND xps_phone != "-1"')
  scope :without_xps_number, where('campaign_id IS NOT NULL AND (xps_phone IS NULL OR xps_phone = "-1")')
  scope :with_twilio, joins(:twilio_number)
  scope :book_apts, where(script_id: 'book_apt')
  scope :with_zip_code, lambda { |zip_code| live.book_apts.joins(business: :address).where(addresses: {zip_code: zip_code}) }

  # When to notify
  store :when_notify, accessors: [:call_receive, :agent_action]
  attr_protected :tenant_id

  #TOTAL_SMS_EMAIL = 3

  belongs_to :tenant
  belongs_to :business
  belongs_to :calendar

  # To notify
  has_many   :notify_numbers, as: :callable, class_name: 'PhoneNumber', conditions: {name: 'notify'}, dependent: :destroy
  has_many   :email_ids, as: :mailable, dependent: :destroy

  # call transfer
  #has_one   :during_hours_number, as: :callable, class_name: 'PhoneNumber', conditions: {name: 'during_hours'}, dependent: :destroy
  #has_one   :after_hours_number, as: :callable, class_name: 'PhoneNumber', conditions: {name: 'after_hours'}, dependent: :destroy

  has_many   :notifications, as: :notifiable
  has_one    :twilio_number, as: :twilioable #, dependent: :destroy
  has_one    :audio_file, as: :audible, dependent: :destroy
  has_one    :phone_script_hour, dependent: :destroy
  has_many   :appointments
  has_many   :phone_script_datas, dependent: :destroy
  has_many   :subscriptions, as: :subscribable
  has_many   :billing_transactions, as: :billable

  delegate :friendly_name, to: :twilio_number
  after_destroy :release_twilio_number
  #after_create :script_mailer
  include NestedModels::EmailIdCallBack
  include NestedModels::PhoneNumberCallBack
  include NestedModels::SoftDeletePhone

  validates :script_id, inclusion: { in: SCRIPT_ID.keys }
  validates :script_id, :business_id, :tenant_id, :name, presence: true

  #accepts_nested_attributes_for :during_hours_number, :after_hours_number
  accepts_nested_attributes_for :phone_script_hour, :audio_file
  accepts_nested_attributes_for :notify_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :email_ids, reject_if: :all_blank, allow_destroy: true

  def script_name
    SCRIPT_ID[script_id]
  end

  def script_number
    SCRIPT_NO[script_id]
  end

  def name_number
    "#{name} #{friendly_name}"
  end

  def phone_number
    "+1#{xps_phone}" if xps_phone && xps_phone != '-1'
  end

  def call_number
    twilio_number.phone_line
  end

  def audio
    if has_audio? && audio_file
      audio_file.record.to_s
    else
      '/defaults/message_records/default.mp3'
    end
  end

  def call_notice?
    call_receive.to_i == 1
  end

  def action_notice?
    agent_action.to_i == 1
  end

  PhoneScriptData::DATA_KEYS.each do |method|
    # getter method
    define_method(method) do
      phone_script_datas.find_by_data_key(method).try(:data_value)
    end

    # setter method
    define_method("#{method}=") do |value|
      #if value.present?
        data = phone_script_datas.find_or_initialize_by_data_key(method)
        data.data_value = value.strip
        data.save
      #end
    end
  end

  private ##################################

  #def script_mailer
  #  ClientMailer.delay.script_created(name, created_at, script_id, self, tenant.owner.email)
  #end
end
