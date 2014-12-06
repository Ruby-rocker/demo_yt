class Voicemail < ActiveRecord::Base
  acts_as_tenant(:tenant)

  ADD_ON_ID = 'voicemail'
  extend CustomFilter
  include NestedModels::SoftDeletePhone

  attr_protected :tenant_id

  belongs_to :tenant
  belongs_to :business
  has_one    :twilio_number, as: :twilioable #, dependent: :destroy
  has_one    :audio_file, as: :audible, dependent: :destroy
  has_many   :email_ids, as: :mailable, dependent: :destroy
  has_many   :subscriptions, as: :subscribable
  has_many   :billing_transactions, as: :billable
  has_many   :notifications, as: :notifiable
  has_many   :add_on_logs, as: :chargeable
  has_one    :add_on, primary_key: 'id', foreign_key: 'type_id', conditions: {type_of: 'Voicemail'}
  has_many   :notify_numbers, as: :callable, class_name: 'PhoneNumber', conditions: {name: 'notify'}, dependent: :destroy

  scope :with_twilio, joins(:twilio_number)

  delegate :friendly_name, to: :twilio_number
  after_destroy :release_twilio_number
  after_create :add_to_add_on
  #after_create  :add_on_create
  include NestedModels::EmailIdCallBack
  include NestedModels::PhoneNumberCallBack

  accepts_nested_attributes_for :audio_file
  accepts_nested_attributes_for :notify_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :email_ids, reject_if: :all_blank, allow_destroy: true

  validates :tenant_id, :business_id, :name, presence: true
scope :super_user_notifications, order('created_at DESC')
  def audio
    audio_file.record.to_s
  end

  def name_number
    "#{name} #{friendly_name}"
  end

  def call_number
    twilio_number.phone_line
  end

  #def add_on_cancel
  #  if tenant.from_admin
  #    true
  #  else
  #    if self.is_deleted?
  #      if self.add_on.add_on_cancellation
  #        ClientMailer.delay.voicemail_cancelled(self.add_on)
  #      end
  #    end
  #  end
  #end

  def add_on_cancel
    if tenant.from_admin
      true
    else
      if self.is_deleted?
        add_on_log = add_on_logs.last_log.first
        if add_on_log.deleted_at.blank?
          add_on_log.deleted_at = Time.now.utc
          add_on_log.save
          result = BraintreeApi.remove_add_on_amount(tenant.subscription_bid, ADD_ON_ID)
          puts "====result = #{result}===================="
          if result[:success]
            true
          else
            add_on_log.deleted_at = nil
            add_on_log.save
            false
          end # if result[:success]
        else
          true
        end # if add_on_log.deleted_at.blank?
      end # if self.is_deleted?
    end # if tenant.from_admin
  end

  private ##################################

  def add_to_add_on
    if tenant.from_admin
      true
    else
      result = BraintreeApi.insert_add_on_amount(tenant.subscription_bid, ADD_ON_ID)
      puts "====result = #{result}===================="
      if result[:success]
        if result[:prorated]
          add_on_log = AddOnLog.new(result[:prorated])
          add_on_log.prorated = true
          add_on_log.chargeable = self
          add_on_log.save
        end
        if result[:next_month]
          add_on_log = AddOnLog.new(result[:next_month])
          add_on_log.chargeable = self
          add_on_log.save
        end
        ClientMailer.delay.voicemail_added(self)
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  #def add_on_create
  #  if tenant.from_admin
  #    true
  #  else
  #    free_add_on = AddOn.free_voicemail.first
  #    if free_add_on
  #      free_add_on.type_id = self.id
  #      free_add_on.save
  #    else
  #      add_on_new = self.build_add_on
  #      if add_on_new.voicemail_phone_menu_add_on
  #        ClientMailer.delay.voicemail_added(self.add_on)
  #      else
  #        raise ActiveRecord::Rollback
  #      end
  #    end
  #  end
  #end

end