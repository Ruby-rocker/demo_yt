module Settings
  class BusinessesController < ApplicationController
    load_and_authorize_resource

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @business = Business.includes(:address).includes(:phone_number).all
    end

    def new
      @business = Business.new
      @business.build_address
      @business.build_phone_number
      add_breadcrumb "Businesses", settings_businesses_path
    end

    def create
      @business = Business.new(params[:business])

      if params[:us_state].present?
        @business.address.state = params[:us_state]
      elsif params[:ca_state].present?
        @business.address.state = params[:ca_state]
      elsif params[:other_state].present?
        @business.address.state = params[:other_state]
      end

      if @business.save
        ClientMailer.delay.business_created(@business)
        @business.notifications.create(title: 'A new business was added to your account', notify_on: Time.now,
           content: "<span>The new business #{@business.name} was created by #{current_user.full_name} and is now available for use.</span>")
        redirect_to settings_businesses_path, notice: "Business saved successfully"
      else
        render :new
      end
    end

    def edit
      @business = Business.find(params[:id])
      add_breadcrumb "Businesses", settings_businesses_path
    end

    def update
      @business = Business.find(params[:business][:id])

      if params[:us_state].present?
        params[:business][:address_attributes][:state] = params[:us_state]
      elsif params[:ca_state].present?
        params[:business][:address_attributes][:state] = params[:ca_state]
      elsif params[:other_state].present?
        params[:business][:address_attributes][:state] = params[:other_state]
      end

      if @business.update_attributes(params[:business])
        ClientMailer.delay.business_updated(@business)
        @business.notifications.create(title: 'A business was edited', notify_on: Time.now,
          content: "<span>The business #{@business.name} was edited by #{current_user.full_name}.</span>")
        redirect_to settings_businesses_path, notice: "Business saved successfully"
      else
        render :edit
      end
    end

    def destroy
      @business = Business.find(params[:id])
      @notification_business = Business.find(params[:id])
      ClientMailer.delay.business_deleted(@business)
      @business.destroy

      @notification_business.notifications.create(title: 'A business was deleted', notify_on: Time.now,
        content: "<span>The business #{@notification_business.name} was deleted by #{current_user.full_name}. All scripts or calendars related to this business have been affected; be sure to resolve any inconsistencies related to these orphans.</span>")
      redirect_to settings_businesses_path, notice: "Business deleted successfully"
    end

    # check for duplicate business name when we try to use from jQuery validations
    def check_business_name
      if params[:business_id].present?
        @business = Business.where("name = ? and id != ? ", params[:business][:name], params[:business_id]).present?
      else
        @business = Business.where("name = ?", params[:business][:name]).present?
      end
      respond_to do |format|
       format.json { render :json => !@business }
      end
    end
  end
end