class Partners::AccountController < ApplicationController
  layout 'partners'
  # PAYMENT_TYPE = {"PAYPAL"=>"PAYPAL" , "BY CHECK" => "BY CHECK"}
  before_filter :check_doc_sign

  def index
    @paypal_type = ["PAYPAL", "BY CHECK"]
    @partner_master = PartnerMaster.find(params[:id])
    @partner_master.phone_number || @partner_master.build_phone_number
    @partner_master.address || @partner_master.build_address
    @paypal_info = PartnerPaymentInformation.find_by_partner_master_id(@partner_master.id) || PartnerPaymentInformation.new
  end

  def update
    @partner_master = PartnerMaster.find(params[:partner_master][:id])
    if params[:us_state].present?
      params[:partner_master][:address_attributes][:state] = params[:us_state]
    elsif params[:ca_state].present?
      params[:partner_master][:address_attributes][:state] = params[:ca_state]
    elsif params[:other_state].present?
      params[:partner_master][:address_attributes][:state] = params[:other_state]
    end

    if @partner_master.update_attributes!(params[:partner_master])
      redirect_to partners_account_index_path(id: params[:partner_master][:id]), notice: "Your account information saved successfully"
    else
      render :index
    end
    if params[:payment_type].present?
      @paypal_info = PartnerPaymentInformation.find_by_partner_master_id(params[:partner_master][:id])
      if @paypal_info.present?
        @paypal_info = @paypal_info.update_attributes(:payment_type => params[:payment_type], :paypal_email => params[:partner_payment_information][:paypal_email])
      else
        @paypal_info = PartnerPaymentInformation.create(:partner_master_id => params[:partner_master][:id], :payment_type => params[:payment_type], :paypal_email => params[:partner_payment_information][:paypal_email])
      end
    end
  end

  def verify_paypal_account
    respond_to do |format|
      format.json { render :json => PaypalApi.verify_paypal_account(params[:paypal_email]).success? }
    end
  end

  private

  def check_doc_sign
    if !current_partner_master.doc_sign
      flash[:alert] = "Please execute the partnership agreement to proceed. If you have any query, contact to YesTrak support team at support@yestrak.com"
      redirect_to partners_partner_docusign_index_path
    end
  end
end
