class ManagePhoneCallsController < ApplicationController

  skip_before_filter :logged_in, :set_defaults, :overage_notice, :set_current_tenant
  before_filter :set_tenant, except: :call_complete
  before_filter :get_call_details, only: [:phone_script, :phone_menu, :voicemail]

  def phone_script
    has_phone_line?('PhoneScript') and return
    response = Twilio::TwiML::Response.new do |r|
      if @phone_number.phone_number
        play_default(r, request.base_url)
        r.Dial @phone_number.phone_number, record: true
      else
        r.Say 'This campaign is not live yet', :voice => 'woman'
      end
    end
    render xml: response.text
  end

  def phone_menu
    has_phone_line?('PhoneMenu') and return
    response = Twilio::TwiML::Response.new do |r|
      if current_tenant.id.eql?(18)  #############################
        r.Gather :numDigits => 5, :action => '/manage_calls/gather_digits', :method => 'post' do |g|
          play_default(r, request.base_url)
          #g.Say 'Please enter your Zip code to be connected to a doctor', :voice => 'woman'
        end
      else   #############################
        r.Gather :numDigits => '1', :action => '/manage_calls/gather_digits', :method => 'post' do |g|
          play_default(r, request.base_url)
          @phone_number.ivr_menu.each do |m|
            g.Say m, :voice => 'woman'
          end
        end
        ## WHEN NO INPUT/DIGIT IS GIVEN
        r.Say 'No input is given', :voice => 'woman'
      end
    end
    render xml: response.text
  end

  def gather_digits
    logger.info("####gather_digitse params #{params.inspect}-----------")
    has_phone_line?('PhoneMenu') and return
    response = Twilio::TwiML::Response.new do |r|
      if current_tenant.id.eql?(18)  #############################
        dial_number = Customizations::IvrZipCode.get_script_id(params['Digits'])
        if dial_number
          r.Dial dial_number, record: false
        else
          r.Say 'The Zip code you entered is not available', :voice => 'woman'
        end
      else   #############################
        dial_number = @phone_number.call_forward(params['Digits'])
        if dial_number
          if current_tenant.id.eql?(1)
            r.Dial record: false do |d|
              d.Number dial_number
            end
            r.Hangup
          else
            r.Dial dial_number, record: false
          end
        else
          r.Say 'The input is not valid', :voice => 'woman'
        end
      end
    end
    render xml: response.text
  end

  def voicemail
    has_phone_line?('Voicemail') and return
    response = Twilio::TwiML::Response.new do |r|
      play_default(r, request.base_url)
      r.Record :action => '/manage_calls/record_call', :method => 'post', maxLength: 120
    end
    render xml: response.text
  end

  def record_call
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Your message is taken, we will get back to you. Thank you', :voice => 'woman'
    end
    render xml: response.text
  end

  def call_complete
    logger.info("****call_complete params #{params.inspect}-----------")
    LongTasks.update_on_call_complete(params[:CallSid], request.subdomain)
    head :ok
    #render nothing: true
  end

  private #######################

  def play_default(r, url)
    #r.Play "http://portal.yestrak.com"+business.message_record.to_s
    r.Play url + @phone_number.audio
  end

  def has_phone_line?(class_name)
    @phone_number = class_name.constantize.find_using_phone_line(params[:To])
    #@phone_number = PhoneMenu.first
    unless @phone_number
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'The number you have dialed not found', :voice => 'woman'
      end
      render xml: response.text
    end
  end

  def set_tenant
    tenant = Tenant.find_using_subdomain(request.subdomain)
    if tenant
      tenant.set_as_active
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Invalid website url', :voice => 'woman'
      end
      render xml: response.text
    end
  end

  def get_call_details
    logger.info("============in get_call_details #{params.inspect}---------------")
    if params[:CallSid]
      call_detail = CallDetail.find_or_initialize_by_call_sid(params[:CallSid])
      call_detail.account_sid = params[:AccountSid]
      call_detail.call_to = params[:To]
      call_detail.call_from = params[:From]
      call_detail.direction = params[:Direction]
      call_detail.from_city = params[:FromCity]
      call_detail.from_country = params[:FromCountry]
      call_detail.from_state = params[:FromState]
      call_detail.from_zip = params[:FromZip]
      call_detail.to_city = params[:ToCity]
      call_detail.to_country = params[:ToCountry]
      call_detail.to_zip = params[:ToZip]
      call_detail.to_state = params[:ToState]
      call_detail.duration = params[:RecordingDuration]
      call_detail.status = params[:CallStatus]
      #call_detail.callable = @phone_number
      call_detail.save
    end
  end

end
