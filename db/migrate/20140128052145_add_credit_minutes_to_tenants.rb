class AddCreditMinutesToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :credit_minutes, :integer, default: 0, null: false, :after => :call_minutes
  end
end
