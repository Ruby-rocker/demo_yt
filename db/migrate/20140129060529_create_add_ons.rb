class CreateAddOns < ActiveRecord::Migration
  def change
    create_table :add_ons do |t|
      t.references  :tenant
      t.references  :subscription
      t.string     :subscription_bid, comment: 'from BrainTree'
      t.string    :customer_bid, comment: 'from BrainTree'
      t.string    :type_of, comment: 'CALL RECORDING, PHONE MENUS, VOICEMAIL BOX'
      t.string     :status, comment: 'active, canceled, past_due, pending, expired'
      t.datetime  :next_due

      t.timestamps
    end

    add_index :add_ons, :tenant_id
    add_index :add_ons, :subscription_id

    remove_column :tenants, :record_status
    remove_column :tenants, :record_call
  end
end
