class AddBalanceToAddOnLogs < ActiveRecord::Migration
  def change
    add_column :add_on_logs, :balance, :decimal, :precision => 8, :scale => 2, default: 0, after: :amount
  end
end
