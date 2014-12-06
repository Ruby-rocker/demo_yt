class CreateSubscriptionsLogs < ActiveRecord::Migration
  def change
    create_table :subscription_logs do |t|
      t.references :tenant
      t.string     :subscription_bid
      t.string     :plan_bid
      t.string     :old_plan_bid
      t.string     :transaction_bid
      t.decimal    :balance, :precision => 8, :scale => 2

      t.timestamps
    end
    add_index :subscription_logs, :tenant_id
  end
end
