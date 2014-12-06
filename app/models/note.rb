class Note < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :appointment
  belongs_to :contact
  belongs_to :user
  belongs_to :phone_script

  attr_protected :tenant_id
  attr_accessor  :xps_phone
  after_create :send_mailer, :if => "via_xps"

  delegate :full_name, :to => :user

  private ########################

  # when call center agent creates note
  def send_mailer
    if phone_script && phone_script.action_notice?
      emails = phone_script.email_ids.pluck(:emails)
      if emails.present?
        ClientMailer.delay(priority: 0).message_taken(self, self.contact, emails)
      end
      # send SMS notice
      twilio_number = phone_script.twilio_number
      if twilio_number.sms
        timestamp = created_at.in_time_zone(phone_script.business.address.timezone).strftime('%b %d %Y, %I:%M%p')
        body = "A message is taken by call center for #{contact.full_name} with contact number #{xps_phone} at #{timestamp}. Message: #{content}"
        ########################
        #bitly =  Bitly.client
        #sms_url = bitly.shorten("http://#{tenant.subdomain}.yestrak.com/contacts?id=#{contact_id}")
        #body = "A message is taken by call center: #{sms_url.short_url} at #{timestamp}"
        #LongTasks.send_sms_notice(twilio_number.phone_line, to_sms, body)
        ########################
        phone_script.notify_numbers.map(&:call_number).each do |number|
          LongTasks.send_sms_notice(twilio_number.phone_line, number, body)
        end
      end # if sms
    end
  end

end
#
#a=AddOn.where(status: 'active').where('subscription_bid IS NOT NULL AND id > 71')
#
#a.each do |i|
#  puts "========ID: #{i.id}================="
#  tenant = i.tenant
#  if tenant && i.subscription_bid.present?
#    s = BraintreeApi.find_subscription(i.subscription_bid) rescue nil
#    if s
#      amount = s.next_billing_period_amount.to_f
#      result = BraintreeApi.insert_add_on_amount_test(tenant.subscription_bid, i.type_of.underscore, amount)
#      ActsAsTenant.with_tenant(tenant) do
#        puts "sssssssssssssuccess: #{result[:success]}================="
#        if result[:success]
#          if result[:prorated]
#            add_on_log = AddOnLog.new(result[:prorated])
#            add_on_log.prorated = true
#            add_on_log.chargeable_type = i.type_of
#            add_on_log.chargeable_id = i.type_id
#            add_on_log.save
#          end
#          if result[:next_month]
#            add_on_log = AddOnLog.new(result[:next_month])
#            add_on_log.chargeable_type = i.type_of
#            add_on_log.chargeable_id = i.type_id
#            add_on_log.save
#          end
#        else
#          puts "===ERROR=====******#{i.id}*****================="
#        end
#      end
#      BraintreeApi.cancel_subscription(i.subscription_bid)
#    end
#  end
#end; nil
