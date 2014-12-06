class AddSubscriptionToTenant < ActiveRecord::Migration
  def change
    remove_column :tenants, :expiry_time
    add_column :tenants, :subscription_bid, :string, after: :has_paid
  end
end
