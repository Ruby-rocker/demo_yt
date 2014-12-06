module Settings
  class VoicemailsController < ApplicationController
    #load_and_authorize_resource
    before_filter :check_cancel
    before_filter :check_active, except: :index
    before_filter :check_owner, only: [:new, :create, :destroy, :choose_number]
    before_filter :find_voicemail, except: [:check_for_uniq_name, :choose_number, :search_local_number, :search_tollfree_number, :destroy]
    before_filter :set_twilio_client, only: [:search_local_number, :search_tollfree_number ]

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @voicemails = Voicemail.all
      @free_voicemail = AddOn.free_voicemail.present?
      respond_to do |format|
        format.html # index.html.erb
      end
    end

    def new
      @voicemail = Voicemail.new
      @businesses = Business.all
      @voicemail.email_ids.present? || @voicemail.email_ids.build
      @voicemail.notify_numbers.present? || @voicemail.notify_numbers.build
      @voicemail.audio_file || @voicemail.build_audio_file
      add_breadcrumb "Voicemails", settings_voicemails_path
    end

    def create
      @voicemail = Voicemail.new(params[:voicemail])
      respond_to do |format|
        if @voicemail.save
          flash[:notice] = 'voicemail was created'
          format.html { redirect_to pick_number_settings_voicemail_path(@voicemail) }
        else
          @businesses = Business.all
          flash[:alert] = 'voicemail was not created, please update your billing info.'
          format.html { render action: "new" }
        end
      end
    end

    def edit
      @voicemail.email_ids.present? || @voicemail.email_ids.build
      @businesses = Business.all
      @voicemail.notify_numbers.present? || @voicemail.notify_numbers.build
      @voicemail.audio_file || @voicemail.build_audio_file
      add_breadcrumb "Voicemails", settings_voicemails_path
    end

    def update
      if params[:voicemail][:audio_file_attributes][:record].present?
        @voicemail.notifications.create(title: 'A voicemail box audio file has been changed', notify_on: Time.now,
          content: "<span>The audio file for the voicemail box #{@voicemail.name} has been changed by #{current_user.full_name}." \
                   "<span>Callers will now hear the new file when they call this voicemail box.</span>")
      end

      hash_emails = params[:voicemail][:email_ids_attributes]
      hash_emails.each_with_index do |(key,value), index|
        # for delete
        value.each do |k,v|
          if (k.eql?("_destroy") and v.eql?("1"))
            @voicemail.notifications.create(title: 'Contact notification information was deleted from a voicemail box', notify_on: Time.now,
                                            content: "<span>The notification address #{value['emails']} was deleted from the voicemail box #{@voicemail.name} by #{current_user.full_name}.</span>" \
                       "<span>Notification messages are no longer being forwarded to this address.</span>")
          end
        end
        # for add
        value.each do |k,v|
          break if @voicemail.email_ids.present? and ((@voicemail.email_ids.count - 1) >= index)
          if k.eql?("emails") and v.present?
            @voicemail.notifications.create(title: 'Contact notification information was added to a voicemail box', notify_on: Time.now,
                                               content: "<span>The notification address #{v} was added to the voicemail box #{@voicemail.name} by #{current_user.full_name}.</span>" \
                       "<span>Notification messages will be forwarded to this address immediately.</span>")
          end
        end
      end
      hash_sms = params[:voicemail][:notify_numbers_attributes]
      hash_sms.each_with_index do |(key,value), index|
        # for delete
        value.each do |k,v|
          if (k.eql?("_destroy") and v.eql?("1"))
            @voicemail.notifications.create(title: 'Contact notification information was deleted from a voicemail box', notify_on: Time.now,
                                            content: "<span>The notification address #{"(#{value['area_code']}) #{value['phone1']}-#{value['phone2']}"} was deleted from the voicemail box #{@voicemail.name} by #{current_user.full_name}.</span>" \
                       "<span>Notification messages are no longer being forwarded to this address.</span>")
          end
        end
        # for add
        sms = 0
        value.each do |k,v|
          break if @voicemail.notify_numbers.present? and ((@voicemail.notify_numbers.count - 1) >= index)
          if (k.eql?("area_code") or k.eql?("phone1") or k.eql?("phone2")) and v.present?
            sms = 1
          end
        end
        if sms.eql?(1)
          sms_number = "(#{value['area_code']}) #{value['phone1']}-#{value['phone2']}"
          @voicemail.notifications.create(title: 'Contact notification information was added to a voicemail box', notify_on: Time.now,
                                             content: "<span>The notification address #{sms_number} was added to the voicemail box #{@voicemail.name} by #{current_user.full_name}.</span>" \
                     "<span>Notification messages will be forwarded to this address immediately.</span>")
        end
      end

      respond_to do |format|
        if @voicemail.update_attributes(params[:voicemail])
          flash[:notice] = 'voicemail box was updated'
          format.html { redirect_to action: :pick_number }
        else
          @businesses = Business.all
          flash[:alert] = 'voicemail box was not updated'
          format.html { render action: "edit" }
        end
      end
    end

    def pick_number
      add_breadcrumb "Voicemails", settings_voicemails_path
      add_breadcrumb "Voicemail Boxes", edit_settings_voicemail_path(@voicemail)
      @twilio_number = @voicemail.twilio_number
      render action: :swap_number if @twilio_number
    end

    def search_local_number
      @phone_number = Voicemail.find(params[:id])
      @numbers = @client.search_local_number(params[:local][:area_code],
                                             params[:local][:keyword], 'US')
      params[:area_code] = params[:local][:area_code]
      params[:keyword] = params[:local][:keyword]
      params[:h1_tag] = 'Displaying results for &gt;&gt; '
      params[:h1_tag] += "<span>#{params[:area_code]}</span>" if params[:local][:area_code].present?
      if params[:local][:keyword].present?
        params[:h1_tag] += " and " if params[:local][:area_code].present?
        params[:h1_tag] += "<span>#{params[:keyword]}</span>"
      end
      params[:h1_tag] += " in <span>#{COUNTRIES['US']}</span>"
      @swap = params[:swap].eql? 'true'
      respond_to do |format|
        format.js { render template: "settings/phone_scripts/search_local_number" }
      end
    end

    def search_tollfree_number
      @phone_number = Voicemail.find(params[:id])
      @numbers = @client.search_tollfree_number(params[:tollfree][:code], params[:tollfree][:keyword], 'US')
      params[:area_code] = params[:tollfree][:code]
      params[:keyword] = params[:tollfree][:keyword]
      params[:tollfree][:code] = params[:tollfree][:code].present? ? params[:tollfree][:code] : 'Any'
      params[:h1_tag] = "Displaying results for &gt;&gt; <span>#{params[:tollfree][:code]}</span>"
      params[:h1_tag] += " and <span>#{params[:tollfree][:keyword]}</span>" if params[:tollfree][:keyword].present?
      @swap = params[:swap].eql? 'true'
      respond_to do |format|
        format.js { render template: 'settings/phone_scripts/search_tollfree_number' }
      end
    end

    def choose_number
      voicemail = Voicemail.find(params[:id])
      if voicemail.twilio_number
        twilio_number = voicemail.twilio_number
      else
        twilio_number = voicemail.build_twilio_number
      end

      phone_number = twilio_number.set_number(params[:number], manage_voicemail_url, manage_call_complete_url)
      if phone_number
        if twilio_number.persisted?
          # swap
          voicemail.notifications.create(title: 'A voicemail number was swapped out', notify_on: Time.now,
                                          content: "<span>The number for the voicemail box #{voicemail.name} was swapped out by #{current_user.full_name}." \
                                                  "<span>Your new number to access this voicemail account is #{voicemail.twilio_number.friendly_name}.</span>")
        else
          # choose
          voicemail.notifications.create(title: 'A new voicemail box was created', notify_on: Time.now,
                                          content: "<span>The new voicemail box #{voicemail.name} was created by #{current_user.full_name}." \
                                                  "<span>Your number to access this voicemail is #{voicemail.twilio_number.friendly_name}. You will be charged $10/month for this service.</span>")
        end
        flash[:notice] = 'voicemail box number selected successfully.'
        redirect_to action: :index
      else
        flash[:alert] = 'Phone number is not available, please try again.'
        redirect_to action: :pick_number
      end
    end

    def destroy
      @voicemail = Voicemail.find(params[:id])
      if current_tenant.is_past_due?
        flash.alert = 'You can not cancel when your status is past due.'
      else
        if @voicemail.try(:soft_delete)
          flash[:notice] = 'voicemail box was deleted.'
          @voicemail.notifications.create(title: 'A voicemail box was deleted', notify_on: Time.now,
                                          content: "<span>The voicemail box #{@voicemail.name} was deleted by #{current_user.full_name}." \
                 "<span>The phone number related to this voicemail is no longer active. You will no longer be charged for this service.</span>")
        else
          flash[:alert] = 'voicemail box was not deleted.'
        end
      end
      respond_to do |format|
        format.html { redirect_to action: :index }
        format.json { head :no_content }
      end
    end

    def check_for_uniq_name
      if params[:id].present?
        voicemail = Voicemail.where('id != ?',params[:id]).where(name: params[:voicemail][:name]).present?
      else
        voicemail = Voicemail.where(name: params[:voicemail][:name]).present?
      end
      respond_to do |format|
        format.json { render :json => !voicemail }
      end
    end

    private ###############################################

    def check_owner
      unless current_user.is_owner?
        flash[:alert] = 'You can not perform this operation, contact super admin.'
        redirect_to action: :index
      end
    end

    def check_active
      if current_tenant.is_past_due?
        flash.alert = 'You can not perform this operation when your status is past due. Update your billing info'
        redirect_to edit_settings_billing_path(current_tenant.billing_info.id)
      end
    end

    def check_cancel
      if current_tenant.is_inactive?
        flash.alert = 'You can not perform this operation when your status is cancelled.'
        redirect_to root_path
      end
    end

    def find_voicemail
      @voicemail = Voicemail.find(params[:id]) if params[:id]
    end

    def set_twilio_client
      @client = TwilioApi.new
    end

  end
end
