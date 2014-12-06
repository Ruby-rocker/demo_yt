ActiveAdmin.register Commission do
  menu :priority => 6, :label => "Commission"
  config.clear_action_items!
  member_action :adjustment, :method => :get do
    @commission_id = params[:id]
    @commission = Commission.new
    render 'admin/credit_amounts/_commission.html.haml'
  end
  collection_action :save_correction, :method => :post do
    @commission = Commission.find(params[:commission][:commission_id])
    @commission.update_attributes(:adjustment => params[:commission][:adjustment])
      respond_to do |format|
        if @commission.save
          format.html {redirect_to commissions_path}
        else
          @commission_id = params[:commission][:commission_id]
          format.html {render 'admin/credit_amounts/_commission.html.haml'}
        end
      end
  end
  member_action :pay_amount, :method => :get do
    
    commission = Commission.find(params[:id])
    partner = PartnerMaster.find(commission.partner_master_id)
    partner_paypal = PartnerPaymentInformation.find_by_partner_master_id(commission.partner_master_id)
    if PaypalApi.verify_paypal_account(partner_paypal.paypal_email).success?
      if commission.present?# || bonus_rec.present?
        total_amount = commission.commission + commission.adjustment
        @mass_pay_response = PaypalApi.mass_pay_request(partner_paypal.paypal_email, total_amount.to_s)
        if @mass_pay_response.success?
            commission.update_attributes(is_paid: 1)
          redirect_to commissions_path, notice: "Payment to #{partner.first_name} #{partner.last_name} is successful with correlationID #{@mass_pay_response.to_hash["ebl:CorrelationID"]}."
        else
          redirect_to commissions_path, notice: "Payment to #{partner.first_name} #{partner.last_name} is not successful."
        end
      else
        redirect_to commissions_path, notice: "There is no pending payment for #{partner.first_name} #{partner.last_name}."
      end
    end
  end


  index do
    column :id
	  #column :user_id
    #column :partner_master_id
    column :partner_master_id do |p|
      partner = PartnerMaster.find(p.partner_master_id)
      partner.first_name + ' ' + partner.last_name
    end
    column :commission
    column :adjustment
    column :is_paid do |s|
      if s.is_paid == true
        "Paid"
      else
        "Unpaid"
      end
    end
    actions  defaults: :true do |commission|
      link_to('Adjustment', adjustment_commission_path(commission), class: "member_link", method: :get)
    end
    column "" do |commission|
      if commission.is_paid == false
        link_to('Pay Amount', pay_amount_commission_path(commission), class: "member_link", data: { confirm: 'Are you sure for Payment?' })
      else
        "Paid"
      end
    end
  end
  controller do

    skip_before_filter :decide_redirection

  end
end
