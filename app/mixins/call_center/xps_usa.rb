module CallCenter
  module XpsUsa
    extend self

    USER_NAME = 'ViziCallAPIUser'
    PASSWORD = 'ViziCall23125!'
    INSERT_BUSINESS = 'http://vizicall.xpsusa.com/vizicall.asmx/InsertBusiness'
    UPDATE_BUSINESS = 'http://vizicall.xpsusa.com/vizicall.asmx/EditBusiness'
    BUSS_HOURS = 'http://vizicall.xpsusa.com/vizicall.asmx/InsertBussHours'
    GET_FORWARDING_NUMBER = 'http://vizicall.xpsusa.com/vizicall.asmx/GetForwardingNumber'
    BUSS_ALERTS = 'http://vizicall.xpsusa.com/vizicall.asmx/InserBussAlerts'
    DEACTIVATE_BUSINESS = 'http://vizicall.xpsusa.com/vizicall.asmx/DeActivateBusiness'
    GET_CALL_RECORDS = 'http://vizicall.xpsusa.com/vizicall.asmx/GetCallRecords'

    def insert_business(phone_script_id, subdomain)
      tenant = Tenant.find_using_subdomain(subdomain)
      param_hash = nil
      ActsAsTenant.with_tenant(tenant) do
        phone_script = PhoneScript.find_by_id(phone_script_id)
        if phone_script && phone_script.twilio_number
          #tenant = phone_script.tenant
          params = {}
          business = phone_script.business
          address = business.address
          phone_script.phone_script_datas.map { |i| params.merge!(i.data_key => i.data_value) }
          if phone_script_id.to_i == 19 || phone_script_id.to_i == 23
            buss_name =  "#{params['buss_name']}  #{phone_script_id}#{tenant.id}"
          else
            buss_name =  "#{params['buss_name']}  #{phone_script_id}"
          end
          param_hash = {APIUserName: USER_NAME, APIPassword: PASSWORD, BussEmail: tenant.owner.email,
                        NotAvailableExecuse: params['not_available_excuse'].to_s, BussContact: tenant.owner.full_name,
                        NextStep: params['next_step'].to_s, ApptType: params['appointment_type'].to_s,
                        Question1: params['question_1'].to_s, Question2: params['question_2'].to_s, Question3: params['question_3'].to_s,
                        BussPhone: business.phone_number.call_number, ApptCost: '0.0',
                        ScriptID: phone_script.script_number, BussName: buss_name,
                        BussFax: '', DesiredAction: params['desired_action'].to_s, ApptDetails: '', NeededInfo: ''}
          param_hash.merge!({BussDescription: business.description.to_s, BussAddress: address.street, BussCity: address.city,
                             BussState: address.state, BussZip: address.zip_code, BussLandMark: business.landmark.to_s})
          if phone_script.script_id.eql?('book_apt')
            phone_script.update_column(:script_auth_token, SecureRandom.hex) if phone_script.script_auth_token.blank?
            param_hash.merge!(iFrameURL: "http://#{tenant.subdomain}.yestrak.com/call_center/#{phone_script.script_auth_token}")
            #param_hash.merge!({Question1: '', Question2: '', Question3: ''})
          else
            param_hash.merge!({iFrameURL: ''})
          end
          if phone_script.campaign_id.blank?
            uri = URI.parse(INSERT_BUSINESS)
            res = Net::HTTP.post_form(uri, param_hash)
            puts "===---------#{res.body}----======="
            begin
              cid = Hash.from_xml(res.body)['NewCampaign']['CampaignID']
              phone_script.update_column(:campaign_id, cid) if cid.present? && res.code.eql?('200') && cid.to_i > 0
            rescue => e
              puts("****===ERROR======= #{e} ****")
            end
          else
            uri = URI.parse(UPDATE_BUSINESS)
            param_hash.merge!(CampaignID: phone_script.campaign_id)
            res = Net::HTTP.post_form(uri, param_hash)
            puts "===---------#{res.body}----======="
            begin
              rid = Hash.from_xml(res.body)['EditCampaign']['ResultID']
            rescue => e
              puts("****===ERROR======= #{e} ****")
            end
          end # eof if phone_script.campaign_id.blank?
        end # eof if phone_script
      end
      param_hash
    end
    handle_asynchronously :insert_business

    def buss_hours(phone_script_id, tenant_id)
      param_hash = nil
      tenant = Tenant.find_by_id(tenant_id)
      ActsAsTenant.with_tenant(tenant) do
        phone_script = PhoneScript.find_by_id(phone_script_id)
        buss_hours = phone_script.phone_script_hour
        campaign_id = phone_script.campaign_id
        if phone_script && buss_hours && campaign_id
          param_hash = {APIUserName: USER_NAME, APIPassword: PASSWORD, CampaignID: campaign_id}
          days = %w(mon tue wed thu fri sat sun)
          days.each do |day|
            case buss_hours.send("#{day}_stat")
              when '0'
                param_hash.merge!("#{day.capitalize}BussHours" => 'close all day')
                param_hash.merge!("#{day.capitalize}CHours" => '')
                #param_hash.merge!("#{day.capitalize}CHours" => 'close all day')
              when '2'
                b_hours = if buss_hours.normal.eql?('false')
                            "#{buss_hours.send('first_'+day+'_open')} - #{buss_hours.send('first_'+day+'_close')} and #{buss_hours.send('second_'+day+'_open')} - #{buss_hours.send('second_'+day+'_close')}"
                          else
                            "#{buss_hours.send('first_'+day+'_open')} - #{buss_hours.send('first_'+day+'_close')}"
                          end
                #b_hours = "#{buss_hours.send('first_'+day+'_open')} - #{buss_hours.send('second_'+day+'_close')}"
                #c_hours = "#{buss_hours.send('first_'+day+'_open')} - #{buss_hours.send('first_'+day+'_close')} and #{buss_hours.send('second_'+day+'_open')} - #{buss_hours.send('second_'+day+'_close')}"
                param_hash.merge!("#{day.capitalize}BussHours" => b_hours)
                param_hash.merge!("#{day.capitalize}CHours" => '')
                #param_hash.merge!("#{day.capitalize}CHours" => c_hours)
              when '1'
                param_hash.merge!("#{day.capitalize}BussHours" => 'open all day')
                param_hash.merge!("#{day.capitalize}CHours" => '')
                #param_hash.merge!("#{day.capitalize}CHours" => 'open all day')
            end # end case
          end # days.each do |day|
          puts "param_hash = #{param_hash.inspect}"
          uri = URI.parse(BUSS_HOURS)
          res = Net::HTTP.post_form(uri, param_hash)
          puts "===---------#{res.body}----======="
        end
      end
      param_hash
    end
    handle_asynchronously :buss_hours

    # will be run every 15 minute to get xps number
    def get_forwarding_number
      puts "===========in get_forwarding_number #{Time.now}"
      uri = URI.parse(GET_FORWARDING_NUMBER)
      param_hash = {APIUserName: USER_NAME, APIPassword: PASSWORD}
      PhoneScript.unscoped.where(is_deleted: false).without_xps_number.with_twilio.each do |phone_script|
        param_hash.merge!(CampaignID: phone_script.campaign_id)
        res = Net::HTTP.post_form(uri,param_hash)
        puts "*********res.body =  #{res.body}"
        xps_phone = Hash.from_xml(res.body)["ForwardingNumber"]["FordwardingNumber"]
        phone_script.update_column(:xps_phone, xps_phone)
        if xps_phone && xps_phone != '-1'
          ClientMailer.delay.new_script_active(phone_script.name, phone_script.created_at, phone_script.tenant.owner.first_name, phone_script.tenant.owner.email, phone_script)
        end
        puts "==== xps_phone = #{xps_phone}=====in -> campaign_id = #{phone_script.id} loop #{Time.now}"
      end
    end

    def time_to_minutes(time)
      minutes = time.include?(':') ? time.split(':').map(&:to_i) : nil
      if minutes
        minutes[1] += 1 if minutes.last > 0
        minutes[1] += minutes.first * 60
        minutes[1]
      else
        0
      end
    end

    # will be run every day
    def get_call_records(date=nil)
      date ||= Date.yesterday
      uri = URI.parse(GET_CALL_RECORDS)
      param_hash = {APIUserName: USER_NAME, APIPassword: PASSWORD, StartDate: "#{date.to_s} 00:00:00", EndDate: "#{date.to_s} 23:59:59"}
      res = Net::HTTP.post_form(uri, param_hash)
      #Time.now.in_time_zone("Bogota")
      #puts "*********res.body =  #{res.body}"
      call_detail = Hash.from_xml(res.body)['DataSet']["diffgram"]['NewDataSet']['Table1']
      if call_detail.class.eql?(Array)
        call_detail.each do |i|
          phone_script_call = PhoneScriptCall.new
          phone_script_call.campaign_id= i['SiteId']
          phone_script_call.talk_time= i['TalkTime']
          phone_script_call.hold_time=  i['HoldTime']
          phone_script_call.call_time=  i['CallTime']
          phone_script_call.name= i['Name']
          phone_script_call.xps_phone=  i['ForwardingNumber']
          phone_script_call.disposition= i['Disposition']
          phone_script_call.agent_name=  i['Agent']
          phone_script_call.tenant_id = PhoneScript.unscoped.find_by_campaign_id(i['SiteId']).try(:tenant_id)
          phone_script_call.total_time= time_to_minutes(phone_script_call.talk_time)
          phone_script_call.save if phone_script_call.tenant_id
          puts " #{i['CallTime']} - #{i['ForwardingNumber']} - #{i['HoldTime']} - #{i['TalkTime']} - #{i['SiteId']} - #{i['Disposition']}"
        end; nil
        PhoneScriptCall.update_tenant_call_minutes! # UPDATE TENANT
        ClientMailer.delay.xps_call_data(date, Time.now, call_detail.size)
        puts "===#{call_detail.size}====GET_CALL_RECORDS date = #{date}  time = #{Time.now}"
      else #hash
        ClientMailer.delay.xps_call_data(date, Time.now)
        puts "===NO RECORD====GET_CALL_RECORDS date = #{date}  time = #{Time.now}"
      end
    end

    #Todo
    def buss_alerts

    end

    #------- XPS DEACTIVATE -----------
    def deactivate_business(campaign_id)
      if campaign_id.present?
        param_hash = {APIUserName: USER_NAME, APIPassword: PASSWORD, CampaignID: campaign_id}
        uri = URI.parse(DEACTIVATE_BUSINESS)
        res = Net::HTTP.post_form(uri, param_hash)
        puts "*********res.body =  #{res.body}"
        phone_script = PhoneScript.unscoped.where(campaign_id: campaign_id).first
        ClientMailer.delay.script_deleted(phone_script)
      end
    end
    handle_asynchronously :deactivate_business

  end

end

#CallCenter::XpsUsa::insert_business_without_delay(19,'drdionpresents')
#CallCenter::XpsUsa::insert_business_without_delay(23,'thechiropractors')
#23='thechiropractors' 31784, 19 = 'drdionpresents'  31783
#["31583", "31616"]
#+18557907604 	(855) 790-7604 	US 	31515 	8558263027
#+13109064308 	(310) 906-4308 	US 	31516 	8558263031
#+12343862607 	(234) 386-2607 	US 	31517 	8558263032
#+12318896484 	(231) 889-6484 	US 	31518 	8558263029
#BussName:
#BussDescription:
#BussAddress:
#BussCity:
#BussState:
#BussZip:
#BussLandMark:
#BussPhone:
#BussFax:
#
#(570) 445-2957 	US 	31559 	 	8558287191
#(913) 325-4389 	US 	31562 	 	8558287194
#(415) 660-9548 	US 	31564 	 	8558366916
#(415) 660-9596 	US 	31563 	 	8558366917
#(520) 762-6536 	US 	11652 		8662184382
#(570) 445-2917 	US 	31566 	 	8662389164
#(775) 235-4336 	US 	31567 	 	8662755059
#(702) 728-4745 	US 	30757 	 	8662814943
#(217) 861-4819 	US 	31615 	 	8663381704
#(239) 494-3567 	US 	30950 	 	8665234230
#XXX(217) 408-4726 	US 	31616 	 	8665725838
#(828) 318-8110 	US 	31252 	 	8667559012
#(224) 400-6837 	US 	31036 	 	8667976795
#(702) 728-4435 	US 	30758 	 	8668059622
#(224) 803-2974 	US 	30937 		8668539203
#(775) 545-4418 	US 	31568 	 	8668755347
#(703) 997-6362 	US 	31283 	 	8668970367
#(646) 493-0752 	US 	30872 	 	8772298253
#XXX(615) 247-5113 	US 	31583 	 	8775489629
#(512) 270-3114 	US 	30723 		8776589356
#(832) 924-0458 	US 	30724 		8776589361
#(512) 201-2628 	US 	30725 	 	8776589363
#(469) 275-4091 	US 	30726 		8776589365
#(325) 387-8259 	US 	30727 	 	8776589371
#(702) 728-4664 	US 	30756 	 	8776589373
#(913) 305-5470 	US 	31160 	 	8882377178
#(972) 885-6290 	US 	31158 	 	8882420636
#(425) 296-8414 	US 	31161 	 	8882423803
#(425) 296-4107 	US 	31162 	 	8882423809
#(786) 422-5743 	US 	22406 	 	8883865181
#(646) 663-5919 	US 	30957  	8558073991
#(646) 681-3785 	US 	30956 	8558073992
#(224) 803-2472 	US 	30986 	8558073993
#(913) 305-5538 	US 	30953 	8558073994
#(646) 663-5826 	US 	30988 	8558073995
#(239) 970-6186 	US 	31031 	8558073996
#(234) 312-6863 	US 	31030 	8558073997
#(646) 681-6296 	US 	31034 	8558073998
#(646) 681-6294 	US 	31035 	8558073999
#(866) 580-4012 	US 	31519 	8558263028
#(715) 953-4423 	US 	31545 	8558263034
#(715) 942-7948 	US 	31546 	8558263035
#(715) 318-3587 	US 	31547 	8558287185
#(850) 397-4406 	US 	31557 	8558287189
#(850) 213-1971 	US 	31558   8558287190
#ScriptID:
#
#BussContact:
#BussEmail:
#ApptType:
#NotAvailableExecuse:
#ApptCost:
#ApptDetails:
#NextStep:
#Question1:
#Question2:
#Question3:
#NeededInfo:
#DesiredAction:
