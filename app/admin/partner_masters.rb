ActiveAdmin.register PartnerMaster do
  menu :priority => 7, :label => "Partners"
  form do |f|
	  f.inputs do
	    f.input :first_name
	    f.input :last_name
	    f.input :email
	    f.input :notes#, :as => :ckeditor
	    f.input :doc_sign, :hint => "Tick to Approved (Approval email notification will send to partner)", :label => "Partner Status"
    end
	  f.buttons
	end

  member_action :download, :method => :get do
    audio_file = AudioFile.unscoped.where(audible_id: params[:id], audible_type: 'PartnerMaster').first
    if audio_file
      send_file("#{Rails.root}/public"+audio_file.record.to_s.split('?').first,
                :filename => audio_file.record_file_name,
                type: audio_file.record_content_type,
                :disposition => 'attachment')
    else
      flash[:alert] = 'No agreement uploaded.'
      redirect_to partner_masters_path
    end
  end
  member_action :login, :method => :put do
    partner = PartnerMaster.find(params[:id])
    redirect_to login_from_admin_site_url(partner.authentication_token, subdomain: APP_CONFIG['partner_subdomain'])
  end
  member_action :pay_commiossion, :method => :put do
    @partner = PartnerMaster.find(params[:id])
    @partner_paypal = PartnerPaymentInformation.find_by_partner_master_id(@partner.id)
    @commission = Commission.where("partner_master_id IN (?)", @partner.id)
    @bonus = Bonus.find_by_partner_master_id(@partner.id)
    redirect_to @partner.paypal_url(thank_you_paypal_partner_masters_url(params[:id]), @commission, @partner_paypal, @bonus)
  end
  collection_action :thank_you_paypal, :method => :get do
    redirect_to partner_masters_path
  end

  member_action :pay_amount, :method => :get do
    partner = PartnerMaster.find(params[:id])
    partner_paypal = PartnerPaymentInformation.find_by_partner_master_id(partner.id)
    if PaypalApi.verify_paypal_account(partner_paypal.paypal_email).success?
      commissions = Commission.where("partner_master_id IN (?) AND is_paid = ?", partner.id, 0)
      total_commission = commissions.map{|c| c.commission}.inject(:+)
      bonus_rec = Bonus.find_by_partner_master_id_and_is_paid(partner.id, 0)
      
      if commissions.present?
        total_amount = bonus_rec.present? ? total_commission + bonus_rec.bonus : total_commission
        @mass_pay_response = PaypalApi.mass_pay_request(partner_paypal.paypal_email, total_amount.to_s)
        if @mass_pay_response.success?
          commissions.map{|c| c.update_attributes(is_paid: 1)}
          bonus_rec.update_attributes(is_paid: 1) if bonus_rec.present?
          redirect_to partner_masters_path, notice: "Payment to #{partner.first_name} #{partner.last_name} is successful with correlationID #{@mass_pay_response.to_hash["ebl:CorrelationID"]}."
        else
          redirect_to partner_masters_path, notice: "Payment to #{partner.first_name} #{partner.last_name} is not successful."
        end
      else
        redirect_to partner_masters_path, notice: "There is no pending payment for #{partner.first_name} #{partner.last_name}."
      end
    else
      redirect_to partner_masters_path, notice: "Email address for paypal account is not varified."
    end
  end

  index do
    column :id
    column :email
    column :first_name
    column :last_name
    column :notes
    #default_actions
    actions defaults: true do |partner|
      link_to('Download', download_partner_master_path(partner), class: "member_link", method: :get, target: :blank)
      
    end
    column "" do |partner|
      link_to('Login', login_partner_master_path(partner), class: "member_link", method: :put, target: :blank)
    end

    # column "" do |partner|
    #   link_to('Pay Amount', pay_amount_partner_master_path(partner), class: "member_link") #if user.is_service_user?
    # end

  end

  controller do
    skip_before_filter :decide_redirection

    def update
      partner_master = PartnerMaster.find(params[:id])
      partner_master_doc_sign = partner_master.doc_sign
      partner_master.update_attributes(params[:partner_master])
      if partner_master_doc_sign == false
          UserMailer.delay.partner_approval(params[:partner_master][:email])
      end
      flash[:notice] = "Partner master successfully updated..."
      redirect_to partner_master_path
    end

    def download2
      send_file("#{Rails.root}/storage/call_recordings/#{params[:sid]}.mp3",
                :filename => "#{params[:sid]}.mp3",
                type: "audio/mpeg",
                :disposition => 'attachment')
    end
  
  end
end
