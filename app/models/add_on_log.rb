class AddOnLog < ActiveRecord::Base
  acts_as_tenant(:tenant)

  CALL_RECORD = 'CallRecord'
  VOICEMAIL = 'Voicemail'
  PHONE_MENU = 'PhoneMenu'
  CALL_RECORD_ADD_ON = 'call_record'
  ADD_ON_PRICE = 10.0

  belongs_to :tenant
  belongs_to  :chargeable, polymorphic: true
  attr_protected :tenant_id

  scope :last_log, where(prorated: false).order('end_date DESC')

  class << self

    def active_voicemails
      where(chargeable_type: 'Voicemail', prorated: false).group(:chargeable_id)
      .where("chargeable_id NOT IN (SELECT chargeable_id FROM add_on_logs WHERE deleted_at IS NOT NULL AND chargeable_type = 'Voicemail')")
      #SELECT * FROM yestrak_development.add_on_logs where chargeable_type = 'Voicemail' and
      #chargeable_id not in (SELECT chargeable_id FROM add_on_logs where deleted_at is not null
      #and chargeable_type = 'Voicemail') group by chargeable_id
    end

    def active_phone_menus
      where(chargeable_type: 'PhoneMenu', prorated: false).group(:chargeable_id)
      .where("chargeable_id NOT IN (SELECT chargeable_id FROM add_on_logs WHERE deleted_at IS NOT NULL AND chargeable_type = 'PhoneMenu')")
    end

    def active_call_record
      last_log.where(chargeable_type: 'CallRecord').where('deleted_at IS NULL').first
    end

    def monthly_charges(date)

    end

  end
  #AddOnLog.where(start_date: , end_date: ,chargeable_id: , chargeable_type: 'Voicemail', tenant_id: , amount:)
  def deleted?
    deleted_at.present?
  end

  def alive?
    !deleted?
  end

  def call_record_add_on
    self.chargeable_type = CALL_RECORD
    if tenant.from_admin
      if self.persisted?
        set_as_deleted!
        unsubscription_notice
      else
        self.amount = ADD_ON_PRICE
        self.save
        subscription_notice
      end
    else # if tenant.from_admin
      if self.persisted? # cancel subscription
        result = BraintreeApi.remove_add_on_amount(tenant.subscription_bid, CALL_RECORD_ADD_ON)
        puts "====unsubscribe result = #{result}===================="
        if result[:success]
          set_as_deleted!
          unsubscription_notice
        else
          false
        end # if result[:success]
      else # subscribe
        result = BraintreeApi.insert_add_on_amount(tenant.subscription_bid, CALL_RECORD_ADD_ON)
        puts "====subscribe result = #{result}===================="
        store_result(result)
        subscription_notice
      end
    end
  end

  def chargeable
    chargeable_type.constantize.unscoped { super }
  end

  private ####################################################

  def store_result(result)
    if result[:success]
      if result[:prorated]
        prorated_add_on = AddOnLog.new
        prorated_add_on.chargeable_type = CALL_RECORD
        prorated_add_on.attributes = result[:prorated]
        prorated_add_on.prorated = true
        prorated_add_on.save
      end
      if result[:next_month]
        self.attributes = result[:next_month]
        self.save
      end
    else
      false
    end
  end

  def set_as_deleted!
    self.deleted_at = Time.now.utc
    self.save
  end

  def subscription_notice
    ClientMailer.delay.call_recordings_subscribed(self.updated_at, self.tenant.timezone, self.tenant.owner.email)
    Notification.create(title: 'You have subscribed to call recording', notifiable_type: 'Recording', notify_on: Time.now,
                        content: "<span>Call recording was added to your system by #{self.tenant.owner.full_name}. You will be charged $10/month for this service.</span>")
  end

  def unsubscription_notice
    ClientMailer.delay.call_recordings_subscription_canceled(self.updated_at, self.tenant.timezone, self.tenant.owner.email)
    Notification.create(title: 'You have unsubscribed from call recording', notifiable_type: 'Recording', notify_on: Time.now,
                        content: "<span>#{self.tenant.owner.full_name} has unsubscribed from call recording for your system. You will no longer be charged for this service.</span>")
  end

end
