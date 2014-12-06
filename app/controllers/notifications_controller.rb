class NotificationsController < ApplicationController
	#load_and_authorize_resource
  #skip_before_filter :set_defaults

  def index
    if session[:sid]
      redirect_to voicemail_recording_path(session[:sid])
    else
      @search = params[:search][:date] rescue nil
      @date_from = params[:search][:date_from] rescue nil
      @date_to = params[:search][:date_to] rescue nil
      @notifications = Notification.filter(params[:search], current_user.is_staff?) #.limit(10)
      @total_record = @notifications.size
      @page_no = (@total_record/10.0).ceil
      @notifications = @notifications.page(params[:page]).per(10)
      @page = (params[:page].nil? ? 2 : params[:page].to_i + 1)
      @blogs = BlogDetail.find(:all, conditions: {post_status: true, trash_status: false}, :order => "post_id DESC", :limit => 2)
      respond_to do |format|
        format.html # show.html.erb
        format.js {}
      end
    end
  end

  def daterange_selector
    render partial: 'daterange_selector'
  end

  def create_user_notification_entry
    notifications_id = current_user.read_true
    notice_list = notifications_id.blank? ? Notification.all : Notification.unread(notifications_id)
    notice_list.each do |notification|
      notification.user_notifications.create(user_id: current_user.id)
    end
    head :ok
  end
end