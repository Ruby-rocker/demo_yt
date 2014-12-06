ActiveAdmin.register Announcement do
  actions :all, :except => [:destroy, :new, :edit]
  menu :priority => 1, :label => "Announcement", :parent => "AllTenant"

  config.filters = false

  action_item :only => [:index] do
     link_to('Send Announcement', announcement_announcements_path , method: :get)
  end

  collection_action :announcement, :method => :get do
    render 'admin/users/announcement'
  end

  collection_action :send_announcement, :method => :post do
    if params[:email_content].blank?
      redirect_to announcement_announcements_path, alert: 'Provide email content'
    else
      if params[:user_id].blank?
        email = User.unscoped.pluck(:email)
        user_id = nil
        #tenant_id = nil
      else
        email = User.unscoped.find(params[:user_id]).email
        user_id = params[:user_id]
        #tenant_id = User.unscoped.find(params[:user_id]).tenant_id
      end

      if params[:email_content].present?
        Announcement.create(message: params[:email_content], user_id: user_id, via_email: 1, via_sms: 0)
        UserMailer.delay.announcement(params[:email_content],email)
      end

      #if params[:sms_content].present?
      #  Announcement.create(message: params[:sms_content], user_id: user_id, via_email: 0, via_sms: 1)
      #end

      #notification_content = ActionView::Base.full_sanitizer.sanitize(params[:email_content])
      #if notification_content.length >= 200
      #  notification_content = "Please check your email for the content of this message"
      #end
      #
      #announcement.notifications.create(title: 'You have received a system announcement from YesTrak', tenant_id: tenant_id, notify_on: Time.now,
      #                    content: "<span>#{notification_content}</span>")

      redirect_to announcement_announcements_path, notice: 'Announcement will be delivered in a few minutes'
    end
  end

  index do
    column :id
    column :message
    column "Recipient", :user do |u|
      if u.user.nil?
        "All Users"
      else
        u.user.full_name
      end
    end
  end

  controller do
    before_filter :reset_tenant

    skip_before_filter :decide_redirection

    def reset_tenant
      ActsAsTenant.current_tenant = nil
    end
  end
end
