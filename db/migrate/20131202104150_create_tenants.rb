class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string  :subdomain
      t.integer :call_minutes, default: 0
      t.string  :customer_bid, comment: 'from BrainTree'
      t.boolean :has_paid, :null => false, :default => false
      t.datetime :expiry_time
      t.datetime :next_due
      t.string  :timezone
      t.string  :status, comment: 'from BrainTree'
      t.string  :plan_bid, comment: 'from BrainTree'


      t.timestamps
    end

    add_index :tenants, :subdomain
    add_index :tenants, :customer_bid
  end
end
