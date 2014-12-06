module Api
  module V1
    class ContactsController < ApplicationController
      respond_to :json
      skip_before_filter :logged_in, :set_defaults, :set_current_tenant

      def create
        data = [:campaign_id, :first_name,:last_name,:phone,:message]
        data.each do |d|
          render json: {success: false, error: "Missing parameter: #{d}"} and return unless params[d].present?
        end
        logger.info "#{params[:campaign_id]}"
        phone_script = PhoneScript.unscoped.where(is_deleted: false).find_by_campaign_id(params[:campaign_id])
        if phone_script.present?
          logger.info "#{phone_script.id} -- #{phone_script.campaign_id}"
          ActsAsTenant.with_tenant(phone_script.tenant) do
            phone = params[:phone].squish[0..11].split('-').map(&:strip)
            contact = Contact.existing?(params[:first_name],params[:last_name],phone[0], phone[1], phone[2]) || Contact.new(via_xps: true)
            if contact.new_record?
              contact.first_name = params[:first_name]
              contact.last_name = params[:last_name]

              contact.phone_numbers.build(area_code: phone[0], phone1: phone[1], phone2: phone[2]) if phone.size.eql?(3)
              contact.email_ids.build(emails: params[:email])
            end
            contact.build_address(street: params[:street], suite: params[:apt_suite_floor], city: params[:city],
                                  state: params[:state], zip_code: params[:zip])
            contact.phone_script_id = phone_script.id
            if contact.save
              contact.notes.create(content: "#{params[:message]}. Phone: #{params[:phone]}", via_xps: true,
                                   phone_script_id: phone_script.id, xps_phone: params[:phone]) if params[:message].present?
              contact.notifications.create(title: 'Congrats! A new contact was entered', notify_on: Time.now,
                                            content: "<span>The contact #{contact.full_name} was added to the system by CALL CENTER.</span>" \
                                                     "<span>#{contact.phone_numbers.first.try(:print_number)}</span>")
            else
              render json: {success: false, error: 'Campaign can not be created'} and return
            end
          end  # ActsAsTenant
        else
          logger.info " It failed"
          render json: {success: false, error: 'Invalid campaign_id'} and return
        end
        render json: {success: true}
      end
    end
  end
end