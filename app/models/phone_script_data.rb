class PhoneScriptData < ActiveRecord::Base
  acts_as_tenant(:tenant)

  belongs_to :tenant
  belongs_to :phone_script
  has_many :notifications, as: :notifiable
  attr_accessible :data_key, :data_value

  DATA_KEYS = ['not_available_excuse', 'buss_name', 'desired_action', 'appointment_type', 'next_step',
               'question_1', 'question_2', 'question_3' ]

  PRINT_SCRIPT = {'take_msg' => 'The Take Message', 'book_apt' => 'The Book Appointment',
                 'gather_info' => 'The Gather Information'}

  SCRIPT_ID = {'take_msg'=> 1, 'book_apt'=> 2, 'gather_info'=> 3}

  validates :data_key, inclusion: { in: DATA_KEYS }
  validates :data_key, uniqueness: {scope: :phone_script_id}
  validates :tenant_id, :phone_script_id, :data_key, presence: true
end
