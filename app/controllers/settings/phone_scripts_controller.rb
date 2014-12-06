module Settings
  class PhoneScriptsController < ApplicationController
    #load_and_authorize_resource
    add_breadcrumb "Settings", :settings_dashboard_index_path

    before_filter :check_cancel
    before_filter :check_active, except: :index
    before_filter :check_owner, only: [:new, :create, :destroy, :choose_number]
    before_filter :set_twilio_client, only: [:search_local_number, :search_tollfree_number ]
    before_filter :find_phone_script, except: [:check_for_uniq_name, :update_script, :choose_number, :search_local_number, :search_tollfree_number, :destroy]
    before_filter :has_twilio_number, only: [:set_script, :routing_notification]

    def index
      @phone_scripts = PhoneScript.all
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @phone_scripts }
      end
    end

    def new
      @phone_script = PhoneScript.new
      @businesses = Business.all
      add_breadcrumb "Phone Scripts", settings_phone_scripts_path
    end

    def create
      @phone_script = PhoneScript.new(params[:phone_script])
      #if params[:phone_script][:script_id].eql?('book_apt')
      #  params[:phone_script][:script_auth_token] = SecureRandom.hex
      #else
      #  params[:phone_script][:script_auth_token] = ''
      #end
      respond_to do |format|
        if @phone_script.save
          # update xps api only if it has twilio number
          #CallCenter::XpsUsa.insert_business(@phone_script.id, request.subdomain)
          flash[:notice] = 'phone script was created'
          format.html { redirect_to pick_number_settings_phone_script_path(@phone_script) }
          format.json { head :no_content }
        else
          @businesses = Business.all
          flash[:alert] = 'phone script was not created'
          format.html { render action: "new" }
          format.json { render json: @phone_script.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      @businesses = Business.all
      add_breadcrumb "Phone Scripts", settings_phone_scripts_path
    end

    # PUT /phone_scripts/1
    # PUT /phone_scripts/1.json
    def update
      #if params[:phone_script][:script_id].eql?('book_apt')
      #  params[:phone_script][:script_auth_token] = SecureRandom.hex
      #else
      #  params[:phone_script][:script_auth_token] = ''
      #end
      respond_to do |format|
        if @phone_script.update_attributes(params[:phone_script])
          # update xps api
          CallCenter::XpsUsa.insert_business(@phone_script.id, request.subdomain)
          flash[:notice] = 'phone script was updated'
          format.html { redirect_to action: :pick_number }
          format.json { head :no_content }
        else
          @businesses = Business.all
          flash[:alert] = 'phone script was not updated'
          format.html { render action: "edit" }
          format.json { render json: @phone_script.errors, status: :unprocessable_entity }
        end
      end
    end

    def pick_number
      add_breadcrumb "Phone Scripts", settings_phone_scripts_path
      add_breadcrumb "Choose Your Desired Outcome", edit_settings_phone_script_path(@phone_script)
      @twilio_number = @phone_script.twilio_number
      @toll_free = ['US', 'CA'].include?(@phone_script.business.address.country)
      render action: :swap_number if @twilio_number
    end

    def check_for_uniq_name
      if params[:id].present?
        phone_script = PhoneScript.where('id != ?',params[:id]).where(name: params[:phone_script][:name]).present?
      else
        phone_script = PhoneScript.where(name: params[:phone_script][:name]).present?
      end
      respond_to do |format|
        format.json { render :json => !phone_script }
      end
    end

    def set_script
      add_breadcrumb "Phone Scripts", settings_phone_scripts_path
      add_breadcrumb "Choose Your Desired Outcome", edit_settings_phone_script_path(@phone_script)
      add_breadcrumb "The Phone Number", pick_number_settings_phone_script_path(@phone_script)
      if @phone_script.script_id.eql?('book_apt')
        @calendars = @phone_script.business.calendars
        render action: :book_apt, layout: 'phone_script'
      end
    end

    def update_script
      mailer = false
      phone_script = PhoneScript.find(params[:id])
      mailer = true if phone_script.phone_script_datas.present?
      phone_script.attributes = params[:phone_script]
      phone_script.save if params[:phone_script][:calendar_id].present?
      # update xps api
      CallCenter::XpsUsa.insert_business(phone_script.id, request.subdomain)
      if mailer
        ClientMailer.delay.script_updated(phone_script.name, phone_script.created_at, phone_script.updated_at, phone_script.script_id, phone_script, phone_script.tenant.owner.email)
        phone_script.notifications.create(title: 'A script was edited', notify_on: Time.now,
          content: "<span>The #{PhoneScript::SCRIPT_ID[phone_script.script_id]} script #{phone_script.name} was edited by #{current_user.full_name}." \
                   "<span>It is available for use now.</span>")
      else
        ClientMailer.delay.script_created(phone_script.name, phone_script.created_at, phone_script.script_id, phone_script, phone_script.tenant.owner.email)
        phone_script.notifications.create(title: 'A new script was created', notify_on: Time.now,
          content: "<span>The new #{PhoneScript::SCRIPT_ID[phone_script.script_id]} script #{phone_script.name} was created by #{current_user.full_name}." \
                   "<span>You will receive an e-mail notification when this script is available for use.</span>")
      end
      redirect_to action: :routing_notification
    end

    def routing_notification
      @phone_script.phone_script_hour || @phone_script.build_phone_script_hour
      #@phone_script.during_hours_number || @phone_script.build_during_hours_number
      #@phone_script.after_hours_number || @phone_script.build_after_hours_number
      @phone_script.notify_numbers.present? || @phone_script.notify_numbers.build
      @phone_script.email_ids.present? || @phone_script.email_ids.build
      @phone_script.audio_file || @phone_script.build_audio_file
      add_breadcrumb "Phone Scripts", settings_phone_scripts_path
      add_breadcrumb "Choose Your Desired Outcome", edit_settings_phone_script_path(@phone_script)
      add_breadcrumb "The Phone Number", pick_number_settings_phone_script_path(@phone_script)
      add_breadcrumb "Help Us With The Script", set_script_settings_phone_script_path(@phone_script)
    end

    def complete
      if @phone_script.audio_file and params[:phone_script][:audio_file_attributes][:record].present?
        @phone_script.notifications.create(title: 'A script audio file has been changed', notify_on: Time.now,
          content: "<span>The audio file for #{@phone_script.name} has been changed by #{current_user.full_name}.</span>" \
                   "<span>Callers will now hear the new file when they call this script.</span>")
      end
      if params[:phone_script][:call_receive] or params[:phone_script][:agent_action]
        hash_emails = params[:phone_script][:email_ids_attributes]
        if hash_emails.present?
          hash_emails.each_with_index do |(key,value), index|
            # for delete
            value.each do |k,v|
              if (k.eql?("_destroy") and v.eql?("1"))
                @phone_script.notifications.create(title: 'Contact notification information was deleted from a script', notify_on: Time.now,
                                                content: "<span>The notification address #{value['emails']} was deleted from #{@phone_script.name} by #{current_user.full_name}.</span>" \
                         "<span>Notification messages are no longer being forwarded to this address.</span>")
              end
            end
            # for add
            value.each do |k,v|
              break if @phone_script.email_ids.present? and ((@phone_script.email_ids.count - 1) >= index)
              if k.eql?("emails") and v.present?
                @phone_script.notifications.create(title: 'New contact notification information was added to a script', notify_on: Time.now,
                  content: "<span>The notification address #{v} was added to #{@phone_script.name} by #{current_user.full_name}.</span>" \
                           "<span>Notification messages will be forwarded to this address immediately.</span>")
              end
            end
          end
        end

        hash_sms = params[:phone_script][:notify_numbers_attributes]
        if hash_sms.present?
          hash_sms.each_with_index do |(key,value), index|
            # for delete
            value.each do |k,v|
              if (k.eql?("_destroy") and v.eql?("1"))
                @phone_script.notifications.create(title: 'Contact notification information was deleted from a script', notify_on: Time.now,
                                                   content: "<span>The notification address #{"(#{value['area_code']}) #{value['phone1']}-#{value['phone2']}"} was deleted from #{@phone_script.name} by #{current_user.full_name}.</span>" \
                         "<span>Notification messages are no longer being forwarded to this address.</span>")
              end
            end
            # for add
            sms = 0
            value.each do |k,v|
              break if @phone_script.notify_numbers.present? and ((@phone_script.notify_numbers.count - 1) >= index)
              if (k.eql?("area_code") or k.eql?("phone1") or k.eql?("phone2")) and v.present?
                sms = 1
              end
            end
            if sms.eql?(1)
              sms_number = "(#{value['area_code']}) #{value['phone1']}-#{value['phone2']}"
              @phone_script.notifications.create(title: 'New contact notification information was added to a script', notify_on: Time.now,
                content: "<span>The notification address #{sms_number} was added to #{@phone_script.name} by #{current_user.full_name}.</span>" \
                         "<span>Notification messages will be forwarded to this address immediately.</span>")
            end
          end
        end
      end

      if @phone_script.phone_script_hour
        phone_script_hour_before = PhoneScriptHour.find_by_phone_script_id(@phone_script.id).attributes
        phone_script_hour_before.delete("updated_at")
      end

      respond_to do |format|
        if @phone_script.update_attributes(params[:phone_script])
          flash.now[:notice] = 'phone script was updated'
          phone_script_hour_after = @phone_script.phone_script_hour.attributes
          phone_script_hour_after.delete("updated_at")
          if @phone_script.phone_script_hour and (phone_script_hour_before != phone_script_hour_after)
             @phone_script.notifications.create(title: 'Script hours have been changed', notify_on: Time.now,
                                               content: "<span>The hours for the script #{@phone_script.name} have been changed by #{current_user.full_name}.</span>")
          end
          format.html { render action: :create_another }
          format.json { head :no_content }
        else
          flash[:alert] = 'phone script was not updated'
          format.html { render action: :routing_notification }
          format.json { render json: @phone_script.errors, status: :unprocessable_entity }
        end
      end
    end

    def search_local_number
      @phone_number = PhoneScript.find(params[:id])
      country = @phone_number.business.address.country
      @numbers = @client.search_local_number(params[:local][:area_code],
                                             params[:local][:keyword], country)
      params[:area_code] = params[:local][:area_code]
      params[:keyword] = params[:local][:keyword]
      params[:h1_tag] = 'Displaying results for &gt;&gt; '
      params[:h1_tag] += "<span>#{params[:area_code]}</span>" if params[:local][:area_code].present?
      if params[:local][:keyword].present?
        params[:h1_tag] += " and " if params[:local][:area_code].present?
        params[:h1_tag] += "<span>#{params[:keyword]}</span>"
      end
      params[:h1_tag] += " in <span>#{COUNTRIES[country]}</span>"
      @swap = params[:swap].eql? 'true'
      respond_to do |format|
        format.js
      end
    end

    def search_tollfree_number
      @phone_number = PhoneScript.find(params[:id])
      @numbers = @client.search_tollfree_number(params[:tollfree][:code], params[:tollfree][:keyword],
                                                @phone_number.business.address.country)
      params[:area_code] = params[:tollfree][:code]
      params[:keyword] = params[:tollfree][:keyword]
      params[:tollfree][:code] = params[:tollfree][:code].present? ? params[:tollfree][:code] : 'Any'
      params[:h1_tag] = "Displaying results for &gt;&gt; <span>#{params[:tollfree][:code]}</span>"
      params[:h1_tag] += " and <span>#{params[:tollfree][:keyword]}</span>" if params[:tollfree][:keyword].present?
      @swap = params[:swap].eql? 'true'
      respond_to do |format|
        format.js
      end
    end

    def choose_number
      phone_script = PhoneScript.find(params[:id])
      if phone_script.twilio_number
        twilio_number = phone_script.twilio_number
      else
        twilio_number = phone_script.build_twilio_number
      end

      phone_number = twilio_number.set_number(params[:number], manage_phone_script_url, manage_call_complete_url)
      if phone_number
        # update xps api only if it has twilio number
        CallCenter::XpsUsa.insert_business(phone_script.id, request.subdomain)
        if twilio_number.persisted?
          # swap
          phone_script.notifications.create(title: 'A phone number has been swapped out', notify_on: Time.now,
            content: "<span>The phone number for the script #{phone_script.name} has been swapped out by #{current_user.full_name}." \
                     "<span>The new phone number is #{phone_script.twilio_number.friendly_name}.</span>")
        end
        flash[:notice] = 'Phone number selected successfully.'
        redirect_to action: :set_script
      else
        flash[:alert] = 'Phone number is not available, please try again.'
        redirect_to action: :pick_number
      end
    end

    # DELETE /phone_scripts/1
    # DELETE /phone_scripts/1.json
    def destroy
      phone_script = PhoneScript.find(params[:id])
      phone_script_notification = phone_script
      phone_script.try(:soft_delete)
      phone_script_notification.notifications.create(title: 'A script was deleted', notify_on: Time.now,
        content: "<span>The #{PhoneScript::SCRIPT_ID[phone_script_notification.script_id]} script #{phone_script_notification.name} was deleted by #{current_user.full_name}." \
                 "<span>The phone line related to this script is no longer active.</span>")
      #ClientMailer.delay.script_deleted(phone_script)
      flash[:notice] = 'phone script was deleted.'
      respond_to do |format|
        format.html { redirect_to action: :index }
        format.json { head :no_content }
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

    def set_twilio_client
      @client = TwilioApi.new
    end

    def find_phone_script
      @phone_script = PhoneScript.find(params[:id]) if params[:id]
    end

    def has_twilio_number
      unless @phone_script.twilio_number
        flash[:alert] = 'You have not set phone number for this phone script.'
        redirect_to action: :pick_number
      end
    end

  end
end
