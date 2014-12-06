class Partners::DashboardController < ApplicationController
  layout 'partners'

  before_filter :check_doc_sign

  def index
    @sale = Array.new
    @partner = current_partner_master
    if @partner.discount_master.present?
      @coupon_code = @partner.discount_master.coupon_code
      partner_state = PartnerStat.all
      partner_state.each do |ps|
        if ps.partner_master_id == current_partner_master.id
          @total = @total.to_i + ps.clicks.to_i
        end
      end
      session[:id] = Array.new
      commission = Commission.where(:partner_master_id => current_partner_master.id)
      commission.each do |commission|
        session[:id] << commission.user_id
          @subscription_billing = Subscription.where('subscribable_id = ? && subscribable_type = ? && status = ?',commission.user_id, 'User', 'active')
          if @subscription_billing.present?
            @subscription_billing.each do |bc|
            if bc.billing_cycle == 4 && commission.commission == 0
                commission.update_attributes(:commission => 100, :is_paid => 0)
            end
          end
        end
      end
      @sale << User.group('DATE(created_at)').where(:id => session[:id]).count
          @sale.each_with_index do |sale, index|
            sale.each_with_index do |s, count|
              @total_sale = @total_sale.to_i + count.to_i
            end
          end 
      @comm = Commission.count(:group => 'user_id', :conditions => ['partner_master_id = ?', current_partner_master.id])
      if (@comm.count >= 10)
          @bonus = Bonus.find_by_partner_master_id(current_partner_master.id)
          if !@bonus.present?
            @bonus = Bonus.create(:partner_master_id => current_partner_master.id, :bonus => 1000)
          end
      end
      @commissions = Commission.all
      @commissions.each do |c|
        if c.partner_master_id == current_partner_master.id
          @total_comm = @total_comm.to_i + c.commission.to_i + c.adjustment.to_i
          @total_correction = @total_correction.to_i + c.adjustment.to_i
        end
      end
      @sale = User.group('DATE(created_at)').where("MONTH(created_at) = ?", Date.today.month).count

    else
      @coupon_code = 'No Coupon Code Set'
    end

  end

  def upload_logo
    if params[:partner_master].present?
      params[:partner_master][:partner_master_id] = current_partner_master.id
      @partner_logo = PartnerLogo.new(params[:partner_master])
      if @partner_logo.save
        flash[:notice] = "Logo uploaded"
      else
        flash[:alert] = "Logo uploaded failed - wrong image type or file size..."
      end
    else
      flash[:alert] = "You must select logo"
    end
    redirect_to partners_dashboard_index_path
  end

  def destroy
    partner_logo = PartnerLogo.find(params[:id])
    partner_logo.destroy
    flash[:notice] = "Logo deleted"
    redirect_to partners_dashboard_index_path
  end

  private

  def check_doc_sign
    if !current_partner_master.doc_sign
      flash[:alert] = "Please execute the partnership agreement to proceed. If you have any query, contact to YesTrak support team at support@yestrak.com"
      redirect_to partners_partner_docusign_index_path
    end
  end
end
