class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :tenant
      t.string     :subscription_bid
      t.string     :customer_id   # BrainTree
      t.string     :plan
      t.string     :plan_bid
      t.string     :status, comment: 'active, canceled, past_due, pending, expired'
      t.references :subscribable, polymorphic: true
      t.decimal    :price, :precision => 8, :scale => 2
      t.decimal    :balance, :precision => 8, :scale => 2
      t.date       :first_billing_date
      t.date       :next_billing_date
      t.date       :billing_period_start_date
      t.date       :billing_period_end_date
      t.date       :paid_through_date
      t.decimal    :next_billing_period_amount, :precision => 8, :scale => 2
      t.string     :wh_kind
      t.datetime   :wh_timestamp
      t.references :discount_detail
      t.string     :discount
      t.references :user

      t.timestamps
    end
    add_index :subscriptions, :tenant_id
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_id, :subscribable_type]
    add_index :subscriptions, :discount_detail_id
  end
end
