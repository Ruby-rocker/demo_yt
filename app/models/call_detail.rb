class CallDetail < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  has_many :recordings, primary_key: 'call_sid', foreign_key: 'call_sid', dependent: :destroy
  belongs_to :twilio_number, :foreign_key => "phone_number_sid", :primary_key => "phone_sid"

  belongs_to :tenant
  belongs_to :callable, polymorphic: true
#belongs_to :twilio_number

  validates :call_sid, presence: true

end
