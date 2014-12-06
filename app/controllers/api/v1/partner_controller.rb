module Api
  module V1
    class PartnerController < ApplicationController
      respond_to :json
      skip_before_filter :logged_in, :set_defaults, :set_current_tenant

      def partner_detail
        coupon = DiscountMaster.find_by_coupon_code_and_active(params[:coupon_code],1)
        if coupon
          partner = coupon.partner_master
          if partner

            partner_landing = partner.partner_landing
            if partner_landing.present?
              content = partner_landing.content
            else
              content = ''
            end

            result = {success: true, partner_coupon_code: coupon.coupon_code, id: partner.id, first_name: partner.first_name, last_name: partner.last_name, content: content }
          else
            result = {success: false, message: 'Partner not found'}
          end
        else
          result = {success: false, message: 'Coupon not found'}
        end
        render json: result
      end

      def partner_logo
        coupon = DiscountMaster.find_by_coupon_code_and_active(params[:coupon_code],1)
        if coupon
          partner = coupon.partner_master
          if partner
            partner_logo = partner.partner_logo
            if partner_logo
              redirect_to ("#{root_url.chop}" + "#{partner_logo.logo.url}")
            else
              #render json: {success: false, message: 'Logo not found'}
              redirect_to ("#{root_url}default_logo.png")
            end
          else
            render json: {success: false, message: 'Partner not found'}
          end
        else
          render json: {success: false, message: 'Coupon not found'}
        end
      end
      def partner_landing_page_click
        coupon = DiscountMaster.find_by_coupon_code_and_active(params[:coupon_code],1)
        if coupon
          partner = coupon.partner_master_id
          if partner
            partner_state = PartnerStat.find_by_ip_address_and_partner_master_id(params[:ip_address], coupon.partner_master_id)
              if partner_state.present?
                partner_state.increment!(:clicks)
                render json: {success: true, message: 'partner state updated'}
              else
                partner_state = PartnerStat.create(:ip_address => params[:ip_address], :partner_master_id => coupon.partner_master_id, :clicks => 1)
                render json: {success: true, message: 'partner state created'}
              end
          else
            render json: {success: false, message: 'Partner not found'}
          end
        else
          render json: {success: false, message: 'Coupon not found'}
        end  
      end

    end
  end
end
