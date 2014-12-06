module Settings
  class UsersController < ApplicationController
    load_and_authorize_resource
    before_filter :owner_only, only: :user_cancellation

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def owner_only
      #redirect_to root_path, alert: 'Unauthorized' if current_tenant.is_inactive?
      redirect_to root_url if !current_user.is_owner?
    end

    def index
    	@users = User.all
    	@user = User.new
    end

    def create
    	@user = User.new(params[:user])
      respond_to do |format|
        if @user.save
          #AdminMailer.delay.subscription_notice(@user.id)
          if params[:user][:role] == "2"
            UserMailer.delay.administrator_added(@user)
          elsif params[:user][:role] == "3"
            UserMailer.delay.user_added(@user)
          end
          flash[:notice] = 'user created successfully'
          @user.notifications.create(title: 'A new user was added to your account', notify_on: Time.now,
            content: "<span>#{@user.full_name} was added as a new #{User::ROLE[@user.role].split(' ')[1]} to your system by #{current_user.full_name}. This #{User::ROLE[@user.role].split(' ')[1]} has been sent log-in information via email.</span>")
          format.html { redirect_to settings_users_path }
        else
          @users = User.all
          flash[:alert] = "users #{@user.errors.messages.keys[0]} #{@user.errors.messages.values[0][0]}"
          format.html { render action: "index" }
        end
      end
    end

    def update
    	@user = User.find(params[:id])
      if params[:user][:email] != @user.email
        params[:user][:confirmation_token] = SecureRandom.hex
        #AdminMailer.delay.subscription_notice(@user.id)
      end
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = 'user updated successfully'
          format.html { redirect_to settings_users_path }
        else
          @users = User.all
          flash[:alert] = "users #{@user.errors.messages.keys[0]} #{@user.errors.messages.values[0][0]}"
          @user = User.new
          format.html { render action: "index" }
        end
      end
    end

    def destroy
    	@user = User.find(params[:id])
      @user_notification = User.find(params[:id])
      if @user.role == User::ADMIN
        #UserMailer.delay.administrator_deleted(@user)
        UserMailer.delay.administrator_deleted(@user.created_at, @user.tenant.timezone, @user.full_name, @user.tenant.owner.email)
      elsif @user.role == User::STAFF
        #UserMailer.delay.user_deleted(@user)
        UserMailer.delay.user_deleted(@user.created_at, @user.tenant.timezone, @user.full_name, @user.tenant.owner.email)
      end
    	@user.destroy
      @user_notification.notifications.create(title: 'A user was deleted', notify_on: Time.now,
        content: "<span>#{User::ROLE[@user.role].humanize} #{@user.full_name} was deleted in your system by #{current_user.full_name}. This user will no longer be able to access your system.</span>")
    	redirect_to settings_users_path
    end

    def check_duplicate_email
      render text: !User.find_by_email(params[:user][:email]).present?
    end

    def edit
      @user = current_user
    end

    def my_account
      @user = User.find(current_user.id)
      if @user.update_attributes(params[:user])
        tenant = current_tenant
        tenant.timezone = params[:account][:timezone]
        tenant.save!
        redirect_to settings_dashboard_index_path, notice: "User Information saved successfully"
      else
        render :edit
      end
    end

    def user_cancellation
      if current_tenant.is_past_due?
        redirect_to :back, alert: 'You can not cancel when your status is past due.'
      else
        @tenant_cancellation = TenantCancellation.find_by_tenant_id(current_user.tenant_id) || TenantCancellation.new
      end
      add_breadcrumb "Billing Overview", settings_billings_path
    end

    def submit_suggestion
      #raise 'submit_suggestion'
      save_reson(params[:tenant_cancellation])
      redirect_to root_url
    end

    def cancellation
      #raise 'cancellation'
      if current_tenant.is_past_due?
        redirect_to :back, alert: 'You can not cancel when your status is past due.'
      else
        save_reson(params[:tenant_cancellation])
        if current_tenant.process_cancellation
          SubscriptionMailer.delay.user_subscription_cancelled(current_tenant)

          current_user.notifications.create(title: 'Account Cancelled', notify_on: Time.now,
            content: "<span>We are sorry to see you go. This confirms your YesTrak account has been cancelled.</span>" \
                     "<span>If you change your mind, it's easy to sign-up again. Simply log into the system and we'll pick up where we left off.</span>")

          redirect_to root_url, :notice => "You have successfully unsubscribed from YesTrak. You can still use this system till #{current_tenant.next_due.strftime('%m/%d/%Y')}"
        else
          redirect_to root_url, :notice => "Cannot process your transaction for your overage minutes. Please check your creditcard information again. You have successfully unsubscribed from YesTrak. You can still use this system till #{current_tenant.next_due}"
        end
      end
    end

    private

    def save_reson(tenant_cancellation)
      @tenant_cancellation = TenantCancellation.find_by_tenant_id(current_user.tenant_id)
      if @tenant_cancellation.present?
        @tenant_cancellation.update_attributes!(tenant_cancellation)
      else
        @tenant_cancellation = TenantCancellation.new(tenant_cancellation)
        #UserMailer.delay.cancellation_notice(current_user)
        @tenant_cancellation.save!
      end
    end
  end
end
