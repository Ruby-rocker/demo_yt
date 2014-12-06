class TwilioApi

  attr_reader :client

  ACCOUNT_SID = 'ACbf138c531f9878a8753716fe0a575374'
  AUTH_TOKEN = 'ca2770b9e385089b6e38996fe03e04f7'

  def initialize(account_sid=nil, auth_token=nil)
    @client = Twilio::REST::Client.new(account_sid || ACCOUNT_SID, auth_token || AUTH_TOKEN)
  end

  # get list of all purchased numbers
  # http://www.twilio.com/docs/api/rest/incoming-phone-numbers
  def purchased_numbers
    client.account.incoming_phone_numbers.list.map(&:phone_number)
  end

  # update voice url for a number   http://vizicall.herokuapp.com/manage_calls/receive_call
  def update_voice_url(phone_sid,voice_url)
    number = client.account.incoming_phone_numbers.get(phone_sid)
    number.update(:voice_url => voice_url)
    #number.voice_url
  end

  # search available local numbers
  def search_local_number(area_code=nil, keyword=nil, country=nil)
    begin
      country_numbers = client.account.available_phone_numbers.get(country)
      if area_code.present? && keyword.present?
        numbers = country_numbers.local.list(area_code: area_code, contains: keyword)
      elsif area_code.present?
        numbers = country_numbers.local.list(area_code: area_code)
      elsif keyword.present?
        numbers = country_numbers.local.list(contains: keyword)
      else
        numbers = country_numbers.local.list
      end
    rescue => e
      numbers = []
      puts "**** #{e} ****"
    end
    numbers[0...10]
  end

  # toll-free only available in us and canada
  def search_tollfree_number(area_code=nil, keyword=nil, country=nil)
    begin
      if ['US', 'CA'].include?(country)
        country_numbers = client.account.available_phone_numbers.get(country)
        if area_code.present? && keyword.present?
          numbers = country_numbers.toll_free.list(area_code: area_code, contains: keyword)
        elsif area_code.present?
          numbers = country_numbers.toll_free.list(area_code: area_code)
        elsif keyword.present?
          numbers = country_numbers.toll_free.list(contains: keyword)
        else
          numbers = country_numbers.toll_free.list
        end
      else
        numbers = []
      end
    rescue => e
      numbers = []
      puts "**** #{e} ****"
    end
    numbers[0...10]
  end

  def purchase_number(phone_number, voice_url, status_callback=nil)
    begin
      number = client.account.incoming_phone_numbers.create(
                      phone_number: phone_number,
                      voice_url: voice_url,
                      status_callback: status_callback
                  )
    rescue => e
      puts "**** #{e} ****"
    end
    number
  end

  def call_log(call_sid)
    client.account.calls.get(call_sid)
  end

  def child_calls_log(call_sid)
    client.account.calls.list(parent_call_sid: call_sid)
  end

  def record_log(record_sid)
    client.account.recordings.get(record_sid)
  end

  def record_by_call(call)
    call.recordings.list
  end

  def send_sms(from, to, body)
    #begin
      client.account.messages.create(
          :from => from,
          :to => to,
          :body => body
      )
    #rescue => e
    #  puts "**** #{e} ****"
    #end
  end

  def destroy(phone_sid)
    begin
      number = client.account.incoming_phone_numbers.get(phone_sid)
      number.delete
    rescue => e
      puts "**** #{e} ****"
    end
  end
end

#https://ACbf138c531f9878a8753716fe0a575374:ca2770b9e385089b6e38996fe03e04f7@api.twilio.com/2010-04-01/Accounts/ACbf138c531f9878a8753716fe0a575374/IncomingPhoneNumbers/PNef0f6dee096e010c7ea75169b2fbb678
#https://api.twilio.com/2010-04-01/Accounts/ACbf138c531f9878a8753716fe0a575374/Usage/Records
#Gather information
#(415) 630-5262
#
#
#Take a message
#(415) 787-4250
#
#////////////old
#
#(415) 660-9596
#(415) 660-9548
#(424) 732-3149
#
#+14247323149
#
#
#t.client.account.usage.records.list({
#  :to => "+14247323149"}).each do |record|
#  puts record.description
#end
#
#t.client.account.calls.list({
#  :to => "(424) 732-3149",
#  :"start_time>" => "2013-12-20",
#  :"start_time<" => "2014-02-06",
#  :PageSize => 1000}).each do |call|
#  puts "#{call.to},#{call.from},#{call.duration},#{call.recordings.list[0].duration rescue 0},#{call.start_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')},#{call.end_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')}"
#end ;nil
#
#t.client.account.calls.list({
#    :to => "(415) 660-9596",
#    :"start_time>" => "2013-12-20",
#    :"start_time<" => "2014-02-15",
#    :PageSize => 1000}).each do |call|
#  puts "#{call.to},#{call.from},#{call.duration},#{call.recordings.list[0].duration rescue 0},#{call.start_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')},#{call.end_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')}"
#end ;nil
#
#t.client.account.calls.list({
#    :to => "(415) 660-9548",
#    :"start_time>" => "2013-12-20",
#    :"start_time<" => "2014-02-15",
#    :PageSize => 1000}).each do |call|
#  puts "#{call.to},#{call.from},#{call.duration},#{call.recordings.list[0].duration rescue 0},#{call.start_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')},#{call.end_time.to_time.strftime('%d %b %Y %I:%M:%S%P %Z')}"
#end ;nil
#https://maps.googleapis.com/maps/api/js/GeocodeService.Search?4snew%20york&7sUS&9sen-US&callback=_xdc_._t5a817&token=58112
#
#https://www.twilio.com/user/account/phone-numbers/available/US/local/search?mode=latlong&page=0&latitude=40.7143528&longitude=-74.0059731&CSRF=1388556426-7bc50ae77aa08e2800890c5f37a24c5b7fa080010ac1f1652819bbd03612179e&CSRF=1388556426-7bc50ae77aa08e2800890c5f37a24c5b7fa080010ac1f1652819bbd03612179e
