class Partners::PartnerHelpsController < ApplicationController
	layout 'partners'
	def index
    @partner_help = PartnerHelp.new
    render "new"
  end

  def new
  end

  def create
    params[:partner_help][:partner_master_id] = current_partner_master.id
    @partner_help = PartnerHelp.new(params[:partner_help])
    if @partner_help.save
      # =========== M A I L E R ============
      ClientMailer.partner_help_notice(@partner_help.id).deliver
      # =========== M A I L E R ============

      redirect_to partners_help_confirmation_path, notice: "We just received your question. A YesTrak representative will be in touch shortly with an answer."
    else
      render :new
    end
  end

  def help_confirmation
  end
end
