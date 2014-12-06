class AddBillingCycle < ActiveRecord::Migration
  def change
    add_column :add_on_logs, :billing_cycle, :integer, after: :prorated
    add_column :billing_transactions, :billing_cycle, :integer, after: :subscription_bid
  end
end
