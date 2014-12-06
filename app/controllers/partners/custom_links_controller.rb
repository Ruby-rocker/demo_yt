class Partners::CustomLinksController < ApplicationController
  layout 'partners'


  before_filter :check_doc_sign

  def index
    partner = PartnerMaster.find(params[:id])
    
    @partner_name = partner.first_name
    if partner.discount_master.present?
      @coupon_code = partner.discount_master.coupon_code
      @partner_landing = PartnerLanding.find_by_partner_master_id(current_partner_master.id)
      if !@partner_landing.present?
      partner_landing_page_data = "<p><strong>(Partner name)</strong> is committed to recommending the finest product and services for you business. We&rsquo;ve partnered with YesTrak because we believe their service is necessary for any business using a phone.</p>

        <p>Gone are the days of the dedicated phone receptionist. Today, your front desk is one part customer service, a dash of marketing, a pinch of billing and 100% get-it-done-no-matter-the-situation all day long.</p>

        <p>With this all-hands-on-deck mentality, it&rsquo;s easy to get caught up in the urgent things at the expense of the truly important ones&hellip;especially when it comes to answering your phones. Too many calls? Send &lsquo;em to night service. Slammed at the front? Put &lsquo;em on hold. Can&rsquo;t talk? Send &lsquo;em to voicemail.</p>

        <p>Three easy ways to deal with the situation at hand&hellip;and just as deadly when you consider the amount of time and money you spend on marketing programs.</p>

        <p><strong>Take care of the phones, and take care of your profits. YesTrak is a ground-breaking live agent solution that not only covers the phones but takes action:</strong></p>

        <ul>
          <li>Customize scripts from any device</li>
          <li>Edit what is said in real-time</li>
          <li>Utilize multiple scripts at once</li>
          <li>Appointments booked right on your calendar</li>
          <li>Information gathered to help you pre-qualify prospects</li>
          <li>Notifications sent to you in real time via SMS Text and email</li>
        </ul>

        <p>Mention or enter coupon code <strong>(Coupon code)</strong> to receive <strong>(Amount or percentage)</strong> FREE</p>"
      
      @partner_landing = PartnerLanding.create(:partner_master_id => current_partner_master.id, :content => partner_landing_page_data)
    end
    else
      @coupon_code = nil
    end
  end
  def edit_partner_page
    @partner_landing = PartnerLanding.find_by_partner_master_id(current_partner_master.id)
    if request.method.eql?('GET')
        render partial: "edit_partner_page"
    else
      if @partner_landing.present?
        @partner_landing.update_attributes(:content => params[:partnerlanding][:content])
        redirect_to partners_custom_links_path(id: current_partner_master.id)
      end
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
