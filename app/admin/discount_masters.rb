ActiveAdmin.register DiscountMaster do
  menu :priority => 6, :label => "Discounts"

  index do
    column :coupon_code
    column :amount
    column :partner_master
    column :active
    column 'Percentage(%)', :percentage
    #column :duration do |d|
    #  d.duration.eql?('first_month') ? 'First Month' : 'Every Month'
    #end
    column :duration do |d|
      d.duration + ' month'
    end
    column :updated_at

    default_actions
  end

  form do |f|
    f.inputs "Discount Details" do
      #f.input :partner_master, :include_blank => "Select partner"
      f.input :partner_master_id, :include_blank => "Select partner", :label => 'Partner', :as => :select, :collection => PartnerMaster.all.map{|p| ["#{p.first_name} #{p.last_name}", p.id]}
      f.input :coupon_code
      f.input :discount_type, :as => :radio, :collection => {'Amount' => '1', 'Percentage' => '2'},
              :input_html => {onchange: "$('#discount_master_amount').prop('disabled', this.value=='2');$('#discount_master_percentage').prop('disabled', this.value=='1');" }
      f.input :amount, input_html: { :disabled => discount_master.discount_type.eql?('2') }
      f.input :percentage, :label => "Percentage(%)", input_html: { :disabled => discount_master.discount_type.eql?('1') }
      #f.input :duration, :label => "Discount applicable for", :as => :select, :collection => {'First month' => 'first_month', 'Every month' => 'every_month'}, :include_blank => false
      f.input :duration, hint: 'Enter no of months.'
      f.input :active, :as => :radio, hint: 'Only active discounts will be applied.'
      f.input :notes#, :as => :ckeditor
    end
    f.actions
  end

  show :title => :coupon_code do |d|
    attributes_table do
      row :id
      row :coupon_code
      row :amount do
        number_to_currency(d.amount)
      end
      row :percentage do
        d.percentage.to_s + '%' if d.percentage
      end
      row :active
      row :partner_master_id
      #row :duration do
      #  d.duration.eql?('first_month') ? 'First Month' : 'Every Month'
      #end
      row :duration do
        d.duration + ' month'
      end
      row :notes
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  filter :coupon_code
  filter :amount
  filter :partner_master
  filter :active
  filter :percentage
  filter :duration, :as => :select, :collection => {'First month' => 'first_month', 'Every month' => 'every_month'}
  filter :updated_at
  filter :created_at

  controller do
    skip_before_filter :decide_redirection
  end
end
