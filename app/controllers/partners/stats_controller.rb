class Partners::StatsController < ApplicationController
  layout 'partners'

  before_filter :check_doc_sign

  def index
    @partner_state = current_partner_master.partner_stats
    @call_records_search = (params[:partner_state_records_search][:date] rescue nil)
    @date_from = (params[:partner_state_records_search][:date_from] rescue nil)
    @date_to = (params[:partner_state_records_search][:date_to] rescue nil)

    session[:limit] = params[:limit] || session[:limit]
    if @partner_state.present?
      @partner_state = @partner_state.filter_for_partner(params[:partner_state_records_search], "", "partners_stats") if (params[:partner_state_records_search] && (params[:partner_state_records_search][:date] || params[:partner_state_records_search][:date_from]))
    end
    # abort @partner_state.inspect
    @displaying_range = PartnerStat.displaying_range

    @clicks = Array.new
    @partner_state.each do |ps|
      @clicks << ps.clicks
    end
    @uniques = PartnerStat.group(:ip_address).where(:partner_master_id => current_partner_master.id).count
    @commission = Commission.where(:partner_master_id => current_partner_master.id)

  end
  def daterange_selector
    render partial: 'daterange_selector'
  end 
  private

  def check_doc_sign
    if !current_partner_master.doc_sign
      flash[:alert] = "Please execute the partnership agreement to proceed. If you have any query, contact to YesTrak support team at support@yestrak.com"
      redirect_to partners_partner_docusign_index_path
    end
  end
end
