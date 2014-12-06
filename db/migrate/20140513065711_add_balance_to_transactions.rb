class AddBalanceToTransactions < ActiveRecord::Migration
  def change
    add_column :billing_transactions, :balance, :decimal, :precision => 8, :scale => 2, default: 0, after: :billing_cycle
    add_column :subscriptions, :billing_cycle, :integer, after: :balance
  end
end
