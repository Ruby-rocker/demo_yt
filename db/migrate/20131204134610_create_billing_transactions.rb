class CreateBillingTransactions < ActiveRecord::Migration
  def change
    create_table :billing_transactions do |t|
      t.references :tenant
      t.references :subscription
      t.references :billable, polymorphic: true
      t.string     :customer_id    # BrainTree

      t.string      :transaction_bid
      t.string      :subscription_bid
      t.string      :status       # submitted_for_settlement
      t.string      :type         # sale, credit
      t.string      :last_4
      t.decimal     :amount, :precision => 8, :scale => 2
      t.datetime    :created_on
      t.datetime    :updated_on
      t.date        :billing_period_start_date
      t.date        :billing_period_end_date

      t.string     :wh_kind
      t.datetime   :wh_timestamp
      t.datetime   :wh_disbursement_date
      t.references :user


      t.timestamps
    end
    add_index :billing_transactions, :tenant_id
    add_index :billing_transactions, [:billable_id, :billable_type]
    add_index :billing_transactions, :subscription_id
    add_index :billing_transactions, :user_id
  end
end
