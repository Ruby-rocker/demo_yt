class ApplicationController < ActionController::Base
  protect_from_forgery
  set_current_tenant_through_filter

  check_authorization :unless => :do_not_check_authorization?

  prepend_before_filter :set_current_tenant, :if => ["chk_google_request", "!request.subdomain.eql?(ADMIN_SUBDOMAIN)", "!request.subdomain.eql?(PARTNER_SUBDOMAIN)"], :except => [:ical]
  before_filter :logged_in, :if => ["chk_google_request", "!request.subdomain.eql?(ADMIN_SUBDOMAIN)", "!request.subdomain.eql?(PARTNER_SUBDOMAIN)"], :except => [:ical]
  before_filter :set_defaults, :if => ["chk_google_request", "chk_default_google_request", "!request.subdomain.eql?(ADMIN_SUBDOMAIN)", "!request.xhr?", "!request.subdomain.eql?(PARTNER_SUBDOMAIN)"]
  before_filter :overage_notice
  before_filter :partner_logged_in, :if => ["request.subdomain.eql?(PARTNER_SUBDOMAIN)"]

  #before_filter :billing_enhancement

  def partner_logged_in
    if !partner_master_signed_in?
      unless params[:controller].include?('devise') || params[:controller].eql?('confirmations') || params[:controller].eql?('sessions')
        redirect_to new_partner_master_session_path, :notice => flash[:notice]
      end
    end
  end

  def check_doc_sign
    if !current_partner_master.doc_sign
      if current_partner_master.audio_file.present?
        flash[:notice] = 'You will get the access once the agreement is verified.'
      else
        flash[:alert] = "Please execute the partnership agreement to proceed. If you have any query, contact to YesTrak support team at support@yestrak.com"
      end
      redirect_to partners_partner_docusign_index_path
    end
  end

  def find_tenant
    if admin_user_signed_in? && session[:selected_tenant]
      tenant = Tenant.find_by_subdomain(session[:selected_tenant])
      if tenant
        tenant.set_as_active
      else
        session[:selected_tenant] = nil
      end
    elsif !admin_user_signed_in?
      session[:selected_tenant] = nil
    end
  end

  def decide_redirection
    if admin_user_signed_in? && session[:selected_tenant].nil?
      redirect_to dashboard_path, :notice => "Please select tenant"
    end
  end

  #rescue_from ActiveRecord::RecordNotFound, with: :no_record_found
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Access denied."
    redirect_to root_url
  end

  helper_method :service_user_signed_in?

  def chk_google_request
    if (params[:code].present? && params[:state].present? && params[:provider].present? && (params[:controller] == "calendars") && (params[:action] == "google_sync"))
      logger.info("***************** chk_google_request false***********************8")
      return false
    else
      return true
    end
  end

  def chk_default_google_request
    if !request.xhr? && service_user_signed_in?
      return true
    end
  end

  def set_defaults
    session[:limit] = session[:limit] || 10
    if current_user.is_super_user?
      notifications_id = current_user.read_true
      @notice_list = notifications_id.blank? ? Notification.all : Notification.unread(notifications_id).reverse()
      @unread_notice = @notice_list.count
      tmp_notifications = @notice_list.any? ? Notification.unread(@notice_list.map(&:id)) : Notification.all
      @notice_list += (tmp_notifications.last(5 - @unread_notice).reverse()) if @unread_notice < 5
    end
    redirect_to new_user_session_path unless current_user.tenant == current_tenant
  end

  def render_not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def logged_in
    if params[:controller] == "devise/registrations" && params[:action] == "new"
      redirect_to LIVE_PRICING_PAGE
    end
    logger.info("====// #{user_signed_in?} //=======")
    logger.info("====referer// #{request.headers['X-Sendfile']} -- #{request.headers['x_sendfile']}//=======")
    logger.info("====url// #{request.url} //=======")
    logger.info("====AGENT class// #{request.user_agent} //=======")
    logger.info("====session// #{session.inspect} //=======")
    logger.info("====// #{controller_name} //=======")
    logger.info("====// #{action_name} //=======")
    unless params[:controller].include?('admin/') || params[:controller].include?('devise') || params[:controller].eql?('confirmations') || params[:controller].eql?('sessions') || current_user || (params[:controller].eql?('users') && params[:action].eql?('new'))
      logger.info("%%%%%%%%%%%%%%%%%%%%%5 #{params[:controller]} &&&5  #{current_user} &&&5 #{params[:action]} %%%%%%%%%%%%%%%%%%%%%%%%%%")
      session[:sid] = params[:sid] if params[:sid] #&& session.loaded?
      #if controller_name.eql?('call_recordings') && action_name.eql?('voicemail') && !session.loaded? #request.referer.eql?(request.url)
      #  logger.info("****** SESSION// #{session.inspect} //=======")
      #else
        redirect_to new_user_session_path, :notice => flash[:notice]
      #end
    end
  end

  def set_current_tenant
    if request.subdomain.blank?
      redirect_to APP_CONFIG['root_url']
    else
      unless params[:controller].eql? "confirmations"
        tenant = Tenant.find_using_subdomain(request.subdomain)
        if tenant
          tenant.set_as_active
          Time.zone = current_tenant.timezone
          # stop user from logging in using an unregistered SUBDOMAIN.
        else
          render :file => "#{Rails.root}/public/wrong_subdomain.html", :status => 404, layout: false
        end
      end
    end
  end

  def service_user_signed_in?
    user_signed_in? && current_user.is_service_user?
  end

  def overage_notice
    if current_tenant && user_signed_in?
      tenant = current_tenant
      if tenant.is_inactive?
        flash[:alert] = "Your YesTrak subscription has been cancelled and your phone numbers have been released. To re-instate your subscription, <a href='#{rejoin_registrations_path(id: current_user.id, token: current_user.authentication_token)}'>Click here</a> to select a plan.".html_safe
        redirect_to root_path if controller_path.include?('settings/')
      end
      if tenant.block_date.present?
        if Date.today < tenant.block_date
          days = (tenant.block_date - Date.today).to_i
          flash[:alert] = "A recent payment attempt was unsuccessful. Please update your credit card information in the 'Billing' section of the Settings page. You have #{days} days left to resolve this payment until your account will be temporarily suspended."
        end
      end
    end
  end

  #def billing_enhancement
  #  if user_signed_in?
  #    flash[:alert] = "The past due amount on your add-on product will be added to your monthly billing going forward. Please refer to the email recently sent titled 'Subscription Billing Enhancements' for more information."
  #  end
  #end

private
  def do_not_check_authorization?
    :devise_controller? || create_account? || params[:controller] == "confirmations"
  end

  def create_account?
    params[:controller].eql?("users") && params[:action].eql?("new")
  end

  def no_record_found
    render :file => "#{Rails.root}/public/422.html", :status => 422
  end
end