class PhoneMenu < ActiveRecord::Base
  acts_as_tenant(:tenant)

  ADD_ON_ID = 'phone_menu'

  include NestedModels::SoftDeletePhone

  TOTAL_DIGIT_KEYS = 9
  belongs_to :tenant
  belongs_to :business
  has_many   :phone_menu_keys, dependent: :destroy

  has_many   :digit_keys, class_name: 'PhoneMenuKey', conditions: "digit != 'other'", dependent: :destroy
  has_one    :other_key, class_name: 'PhoneMenuKey', conditions: {digit: 'other'}, dependent: :destroy

  has_one    :twilio_number, as: :twilioable #, dependent: :destroy
  has_one    :audio_file, as: :audible, dependent: :destroy

  has_many   :subscriptions, as: :subscribable
  has_many   :billing_transactions, as: :billable
  has_many   :notifications, as: :notifiable
  has_many   :add_on_logs, as: :chargeable
  has_one    :add_on, primary_key: 'id', foreign_key: 'type_id', conditions: {type_of: 'PhoneMenu'}

  attr_protected :tenant_id

  accepts_nested_attributes_for :digit_keys, :other_key, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :audio_file


  validates :tenant_id, :business_id, :name, presence: true

  before_validation :destroy_marked_for_destruction
  after_destroy :release_twilio_number
  after_create :add_to_add_on
  #after_create :create_addon

  def ivr_menu
    menu = phone_menu_keys.order(:digit)
    menu.inject([]) {|m, j| m << (j.digit.eql?('other') ? "Press any other digit #{j.phone_number.name}" : "Press #{j.digit} #{j.phone_number.name}") }
  end

  def call_forward(digit)
    key = phone_menu_keys.where(digit: digit).first
    if key
      if key.routable
        key.routable.call_number
      else
        key.phone_number.call_number
      end
    else
      other_key.phone_number.call_number
    end
  end

  def audio
    audio_file.record.to_s
  end

  #def add_on_cancel
  #  if tenant.from_admin
  #    true
  #  else
  #    if self.is_deleted?
  #      if self.add_on.add_on_cancellation
  #        ClientMailer.delay.phone_menu_cancelled(self.add_on)
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
            #add_on_log.deleted_at = result[:deleted_at]
            #add_on_log.save
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

  private #############################################

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
        ClientMailer.delay.phone_menu_added(self)
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  #def add_on_create
  #  if tenant.from_admin
  #    true
  #  else
  #    free_add_on = AddOn.free_phone_menu.first
  #    if free_add_on
  #      free_add_on.type_id = self.id
  #      free_add_on.save
  #    else
  #      add_on_new = self.build_add_on
  #      if add_on_new.voicemail_phone_menu_add_on
  #        ClientMailer.delay.phone_menu_added(self.add_on)
  #      else
  #        raise ActiveRecord::Rollback
  #      end
  #    end
  #  end
  #end

  def destroy_marked_for_destruction
    digit_keys.each do |key|
      key.destroy if key.marked_for_destruction?
    end
  end

  #def create_addon
  #  add_on_create
  #end

end
