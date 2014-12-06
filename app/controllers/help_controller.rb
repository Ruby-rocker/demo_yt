class HelpController < ApplicationController
  def index
    @help = Help.new
    render "new"
  end

  def new
  end

  def create
    params[:help][:user_id] = current_user.id
    @help = Help.new(params[:help])
    if @help.save
      # =========== M A I L E R ============
      ClientMailer.delay.help_notice(@help.id)
      # =========== M A I L E R ============
      @help.notifications.create(title: 'A question has been logged in the Help section', notify_on: Time.now,
                           content: "<span>#{current_user.full_name} has logged a question for YesTrak Customer Care. We will respond with an answer via e-mail as soon as possible.</span>")
      redirect_to help_confirmation_path, notice: "We just received your question. A YesTrak representative will be in touch shortly with an answer."
    else
      render :new
    end
  end

  def help_confirmation
  end
end
