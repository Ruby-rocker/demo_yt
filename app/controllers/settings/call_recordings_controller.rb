module Settings
  class CallRecordingsController < ApplicationController

    before_filter :check_active, except: :index
    before_filter :check_cancel
    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @add_on = current_tenant.record_call_logs.last_log.first
      #@add_on = current_tenant.record_call || current_tenant.build_record_call
    end

    def update_recordings
      if current_user.is_owner?
        add_on = current_tenant.record_call_logs.last_log.first || current_tenant.record_call_logs.new
        if add_on.call_record_add_on
          #flash[:notice] = 'Call Recordings subscription successful'
        else
          flash[:alert] = 'Call Recordings subscription unsuccessful, Update billing info.'
        end
      else
        flash[:alert] = 'You can not perform this operation, contact super admin.'
      end
      redirect_to action: :index
    end

    def update_recordings3
      @add_on = current_tenant.record_call || current_tenant.build_record_call
      if current_user.is_owner?
        if @add_on.call_record_add_on
          #flash[:notice] = 'Call Recordings subscription successful'
        else
          flash[:alert] = 'Call Recordings subscription unsuccessful, Update billing info.'
        end
      else
        flash[:alert] = 'You can not perform this operation, contact super admin.'
      end
      redirect_to action: :index
    end

    def update_recordings2
      tenant = current_tenant
      tenant.transaction do
        begin
          tenant.record_call = params[:tenant][:record_call]
          tenant.save!
          if params[:phone_script]
            params[:phone_script].each_pair do |id, record_call|
              phone_script = PhoneScript.find(id)
              phone_script.record_call = record_call
              phone_script.save!
            end
          end
          flash[:notice] = 'Call recordings updated.'
        rescue => e
          puts "====ERROR====#{e}========"
          flash[:alert] = 'Call recordings not updated.'
          raise ActiveRecord::Rollback
        end
      end
      redirect_to action: :index
    end

    private ####################################################

    def check_active
      if current_tenant.is_past_due?
        flash.alert = 'You can not perform this operation when your status is past due. Update your billing info'
        redirect_to edit_settings_billing_path(current_tenant.billing_info.id)
      end
      unless current_user.is_owner?
        flash[:alert] = 'You can not perform this operation, contact super admin.'
        redirect_to action: :index
      end
    end

    def check_cancel
      if current_tenant.is_inactive?
        flash.alert = 'You can not perform this operation when your status is cancelled.'
        redirect_to root_path
      end
    end

  end
end
