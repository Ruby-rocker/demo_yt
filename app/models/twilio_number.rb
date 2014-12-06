class TwilioNumber < ActiveRecord::Base
  acts_as_tenant(:tenant)

  attr_protected :tenant_id

  store :capability, accessors: [ :voice, :sms, :mms ]

  belongs_to :tenant

  belongs_to :twilioable, polymorphic: true
  #has_many   :call_details
  has_many :call_details, primary_key: 'phone_sid', foreign_key: 'phone_number_sid', dependent: :destroy

  after_destroy :release_twilio_number
  before_save :set_capabilities

  validates :tenant_id, :twilioable_id, :twilioable_type, :phone_sid, :account_sid, :phone_line,
            :friendly_name, :iso_country, presence: true

  TOLL_FREE_CODE = {'# 888' => 888, '# 877' => 877, '# 866' => 866, '# 855' => 855, '# 800' => 800}

  def print_phone_line
    friendly_name.sub(')',' -').sub('(','+1 ')
  end

  def set_number(params, voice_url, status_callback)
    self.attributes = params
    release_twilio_number if self.persisted?
    client = TwilioApi.new
    phone_number = client.purchase_number(phone_line, voice_url, status_callback)
    if phone_number
      self.phone_sid = phone_number.sid
      self.account_sid = phone_number.account_sid
      self.capability = phone_number.capabilities
      self.save
    end
    phone_number
  end

  private #############################################

  def set_capabilities
    self.capability = capability.inject({}) {|m,i| m.merge!({i[0].to_sym => i[1]}) }
  end

  def release_twilio_number
    LongTasks.release_twilio_number(phone_sid)
  end
end
