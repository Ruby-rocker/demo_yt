module Settings
  class PhoneMenusController < ApplicationController
    #load_and_authorize_resource
    before_filter :check_cancel
    before_filter :check_active, except: :index
    before_filter :check_owner, only: [:new, :create, :destroy, :choose_number]
    before_filter :find_phone_menu, except: [:check_for_uniq_name, :choose_number, :search_local_number, :search_tollfree_number, :destroy]
    before_filter :set_twilio_client, only: [:search_local_number, :search_tollfree_number ]

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @phone_menu = PhoneMenu.all
      @free_phone_menu = AddOn.free_phone_menu.present?
      respond_to do |format|
        format.html # index.html.erb
      end
    end

    def new
      @phone_menu = PhoneMenu.new
      @phone_menu.digit_keys.build
      @phone_menu.build_other_key
      get_form_values
      @phone_menu.audio_file || @phone_menu.build_audio_file
      add_breadcrumb "Phone Menus", settings_phone_menus_path
      respond_to do |format|
        format.html
      end

    end

    def create
      @phone_menu = PhoneMenu.new(params[:phone_menu])
      respond_to do |format|
        if @phone_menu.save
          flash[:notice] = 'phone menu was created'
          ClientMailer.delay.phone_menu_created(@phone_menu)
          format.html { redirect_to pick_number_settings_phone_menu_path(@phone_menu) }
        else
          get_form_values
          flash[:alert] = 'phone menu was not created, please update your billing info.'
          format.html { render action: "new" }
        end
      end
    end

    def edit
      @phone_menu.digit_keys.present? || @phone_menu.digit_keys.build
      @phone_menu.other_key || @phone_menu.build_other_key
      get_form_values
      @phone_menu.audio_file || @phone_menu.build_audio_file
      add_breadcrumb "Phone Menus", settings_phone_menus_path
    end

    def update
      if params[:phone_menu][:audio_file_attributes][:record].present?
        @phone_menu.notifications.create(title: 'A phone menu audio file has been changed', notify_on: Time.now,
        content: "<span>The audio file for the phone menu #{@phone_menu.name} has been changed by #{current_user.full_name}." \
                 "<span>Callers will now hear the new file when they call this menu.</span>")
      end
      respond_to do |format|
        if @phone_menu.update_attributes(params[:phone_menu])
          flash[:notice] = 'phone menu was updated'
          ClientMailer.delay.phone_menu_modified(@phone_menu)
          @phone_menu.notifications.create(title: 'A phone menu was edited', notify_on: Time.now,
            content: "<span>The phone menu #{@phone_menu.name} was edited by #{current_user.full_name}.</span>")
          format.html { redirect_to action: :pick_number }
        else
          get_form_values
          flash[:alert] = 'phone menu was not updated'
          format.html { render action: "edit" }
        end
      end
    end

    def pick_number
      add_breadcrumb "Phone Menus", settings_phone_menus_path
      add_breadcrumb "Phone Menu", edit_settings_phone_menu_path(@phone_menu)
      @twilio_number = @phone_menu.twilio_number
      render action: :swap_number if @twilio_number
    end

    def search_local_number
      @phone_number = PhoneMenu.find(params[:id])
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
      @phone_number = PhoneMenu.find(params[:id])
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
      phone_menu = PhoneMenu.find(params[:id])
      if phone_menu.twilio_number
        twilio_number = phone_menu.twilio_number
      else
        twilio_number = phone_menu.build_twilio_number
      end
      phone_number = twilio_number.set_number(params[:number], manage_phone_menu_url, manage_call_complete_url)
      if phone_number
        if twilio_number.persisted?
          # swap
          phone_menu.notifications.create(title: 'A phone menu number was swapped out', notify_on: Time.now,
                                          content: "<span>The number for the phone menu #{phone_menu.name} was swapped out by #{current_user.full_name}." \
                                                  "<span>Your new number to access this menu is #{phone_menu.twilio_number.friendly_name}.</span>")
        else
          # choose
          phone_menu.notifications.create(title: 'A new phone menu was created', notify_on: Time.now,
                                          content: "<span>The new phone menu #{phone_menu.name} was created by #{current_user.full_name}." \
                                                  "<span>Your number to access this menu is #{phone_menu.twilio_number.friendly_name}. You will be charged $10/month for this service.</span>")
        end
        flash[:notice] = 'phone menu number selected successfully.'
        redirect_to action: :index
      else
        flash[:alert] = 'Phone number is not available, please try again.'
        redirect_to action: :pick_number
      end
    end

    def destroy
      @phone_menu = PhoneMenu.find(params[:id])
      if current_tenant.is_past_due?
        flash.alert = 'You can not cancel when your status is past due.'
      else
        if @phone_menu.try(:soft_delete)
          flash[:notice] = 'phone menu was deleted.'
          @phone_menu.notifications.create(title: 'A phone menu was deleted', notify_on: Time.now,
                                           content: "<span>The phone menu #{@phone_menu.name} was deleted by #{current_user.full_name}." \
                                                    "<span>The phone number related to this script is no longer active. You will no longer be charged for this service.</span>")
        else
          flash[:alert] = 'phone menu was not deleted.'
        end
      end
      respond_to do |format|
        format.html { redirect_to action: :index }
      end
    end

    def check_for_uniq_name
      if params[:id].present?
        phone_menu = PhoneMenu.where('id != ?',params[:id]).where(name: params[:phone_menu][:name]).present?
      else
        phone_menu = PhoneMenu.where(name: params[:phone_menu][:name]).present?
      end
      respond_to do |format|
        format.json { render :json => !phone_menu }
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

    def find_phone_menu
      @phone_menu = PhoneMenu.find(params[:id]) if params[:id]
    end

    def get_form_values
      @businesses = Business.all
      @routable = {}
      @businesses.map {|i| @routable['Business'] ? @routable['Business'] << [i.name_number, "Business_#{i.id}"] : @routable['Business'] = [[i.name_number, "Business_#{i.id}"]] }
      PhoneScript.with_twilio.live.map {|i| @routable['Phone Script'] ? @routable['Phone Script'] << [i.name_number, "PhoneScript_#{i.id}"] : @routable['Phone Script'] = [[i.name_number, "PhoneScript_#{i.id}"]] }
      Voicemail.with_twilio.map {|i| @routable['Voicemail'] ? @routable['Voicemail'] << [i.name_number, "Voicemail_#{i.id}"] : @routable['Voicemail'] = [[i.name_number, "Voicemail_#{i.id}"]] }
    end

    def set_twilio_client
      @client = TwilioApi.new
    end

  end
end
