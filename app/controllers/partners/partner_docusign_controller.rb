class Partners::PartnerDocusignController < ApplicationController
  layout 'partners'

  def index
    # manual start
    #@agreement = current_partner_master.audio_file || current_partner_master.build_audio_file
    # manual end
  end

  def upload_agreement
    # manual start
    #@agreement = current_partner_master.audio_file || current_partner_master.build_audio_file
    #@agreement.record = params[:audio_file][:record]
    #@agreement.save
    #flash[:notice] = 'You will get the access once the agreement is verified.'
    #UserMailer.delay.agreement_uploaded(current_partner_master.full_name)
    #redirect_to partners_partner_docusign_index_path
    # manual end
  end

  def embedded_signing
    # manual start
    #redirect_to partners_partner_docusign_index_path
    # manual end

    # hello sign start
    #partner_full_name = current_partner_master.first_name + ' ' + current_partner_master.last_name
    #partner_email = current_partner_master.email
    #embedded_request = HelloSign.create_embedded_signature_request_with_template(
    #    :test_mode => 1,
    #    :title => 'Agreement with YesTrak',
    #    :subject => 'The Agreement we talked about',
    #    :message => 'Please sign this agreement and then we can discuss more. Let me know if you have any questions.',
    #    :template_id => 'cb9055b1b105b9d7211768ea3b22fd003d8f6fcd',
    #    :signers => [
    #      {
    #       :email_address => 'shweta.aagja@softwebsolutions.com',
    #       :name => 'Shweta',
    #       :role => 'Partner'
    #      }
    #    ]
    #    #:signing_redirect_url => "#{PARTNER_URL}partners/partner_docusign/docusign_response",
    #)
    #
    #signature_id = embedded_request.signatures[0].signature_id
    #
    #@signature_request_id = embedded_request.signature_request_id
    #
    #embedded = HelloSign.get_embedded_sign_url :signature_id => signature_id
    #@sign_url = embedded.sign_url
    # hello sign end

    # docusign start
    client = DocusignRest::Client.new
    partner_full_name = current_partner_master.first_name + ' ' + current_partner_master.last_name
    partner_email = current_partner_master.email
    @envelope_response = client.create_envelope_from_template(
        email: {
            subject: "YesTrak Partner Agreement",
            body: "This is Agreement for YesTrak Partner"
        },
        #template_id: "29B56D7A-CC76-4812-90FC-1D7440B615E0",
        template_id: "9862AE01-558F-4D77-845A-C7D013677679",
        signers: [
            {
                embedded: true,
                name: partner_full_name,
                email: partner_email,
                role_name: 'Partner'
            }
        ],
        #files: [
        #    {path: 'public/partneragreement.pdf', name: 'partneragreement.pdf'},
        #],
        status: 'sent'
    )

    @url = client.get_recipient_view(
        envelope_id: @envelope_response["envelopeId"],
        name: partner_full_name,
        email: partner_email,
        return_url: "#{PARTNER_URL}partners/partner_docusign/docusign_response" #docusign_response_partners_partner_docusign_index_path
    )

    #client.get_document_from_envelope(
    #    envelope_id: @envelope_response["envelopeId"],
    #    document_id: 1,
    #    local_save_path: "#{Rails.root.join('YesTrakPartnerAgreement.pdf')}"
    #)

    # docusign end

  end

  def docusign_response
    # hello sign start
    #partner = current_partner_master
    #if params[:event] == "signature_request_signed"
    #
    #  partner.doc_sign = 1
    #  partner.save
    #
    #  # download signed document from hellosign
    #  file_bin = HelloSign.signature_request_files :signature_request_id => params[:signature_request_id], :file_type => 'pdf'
    #  open("yestrak_partner_agreement.pdf", "wb") do |file|
    #    file.write(file_bin)
    #  end
    #
    #  # send mail to partner and admin
    #  UserMailer.you_just_signed('mayank.jani@softwebsolutions.com').deliver
    #
    #  # delete downloaded signed document
    #  File.delete("yestrak_partner_agreement.pdf")
    #
    #  flash[:notice] = "Thanks! Successfully signed"
    #  redirect_to partners_dashboard_index_path
    #else
    #  flash[:notice] = "You chose not to sign the document."
    #  redirect_to partners_partner_docusign_index_path
    #end
    # hello sign end

    # docusign start
    utility = DocusignRest::Utility.new
    partner = current_partner_master
    if params[:event] == "signing_complete"
      flash[:notice] = "Thanks! Successfully signed"
      partner.doc_sign = 1
      partner.save
      render :text => utility.breakout_path(partners_dashboard_index_path), content_type: 'text/html'
    else
      flash[:alert] = "You chose not to sign the document."
      render :text => utility.breakout_path(partners_partner_docusign_index_path), content_type: 'text/html'
    end
    # docusign end

  end
end
