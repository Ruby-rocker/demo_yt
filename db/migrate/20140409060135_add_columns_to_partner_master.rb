class AddColumnsToPartnerMaster < ActiveRecord::Migration
  def change
    remove_column :partner_masters, :name
    add_column :partner_masters, :first_name, :string
    add_column :partner_masters, :last_name, :string
    add_column :partner_masters, :is_deleted, :boolean, default: false, null: false
    add_column :partner_masters, :coupon_code, :string
  end
end
