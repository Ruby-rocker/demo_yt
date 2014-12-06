class Partners::StatementsController < ApplicationController
  layout 'partners'

  before_filter :check_doc_sign

  def index 
    session[:id] = Array.new
    @commission = Commission.where(:partner_master_id => current_partner_master.id)
    @sale = Array.new
    @commission.each do |commission|
      
      session[:id] << commission.user_id
      @statement = User.where("id IN (?)",session[:id]) 
      @sale << User.group('DATE(created_at)').where(:id => commission.user_id).count
    end
    @call_records_search = (params[:partner_statement_records_search][:date] rescue nil)
    @date_from = (params[:partner_statement_records_search][:date_from] rescue nil)
    @date_to = (params[:partner_statement_records_search][:date_to] rescue nil)

    session[:limit] = params[:limit] || session[:limit]
    if @statement.present?
      @statement = @statement.filter_for_partner(params[:partner_statement_records_search], "", "partners_statements") if (params[:partner_statement_records_search] && (params[:partner_statement_records_search][:date] || params[:partner_statement_records_search][:date_from]))
    end
    @bonus = Bonus.new
    @bonus = Bonus.find_by_partner_master_id(current_partner_master.id)
    @displaying_range = PartnerStatement.displaying_range
  end
  def paid_commission
      @commission = Commission.find(params[:commission_id])
      @commission.update_attributes(:is_paid => true)
      redirect_to partners_statements_path
  end
  def paid_bonus
      @bonus = Bonus.find_by_partner_master_id(current_partner_master.id)
      @bonus.update_attributes(:is_paid => true)
      redirect_to partners_statements_path
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
