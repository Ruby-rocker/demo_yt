class AudioFile < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  belongs_to :audible, polymorphic: true
  attr_protected :tenant_id
  attr_accessor :from_partner

  has_attached_file :record,
                    url: "/system/:class/:id/:attachment/:style.:extension",
                    path: ":rails_root/public/system/:class/:id/:attachment/:style.:extension"
                    #default_url: '/defaults/message_records/default.mp3'

  after_create :send_mailer, unless: "from_partner"

  private

  def send_mailer
    if audible_type.eql?("PhoneScript")
      phone_script = PhoneScript.find(audible_id)
      ClientMailer.delay.phone_greeting_uploaded(phone_script, self.tenant.owner.email)
    end
  end

end
