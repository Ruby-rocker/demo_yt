class CreateCallCharges < ActiveRecord::Migration
  def change
    create_table :call_charges do |t|
      t.references  :tenant
      t.string  :call_type
      t.integer :total_min, :default => 0, :null => false
      t.integer :credit_min, :default => 0, :null => false
      t.integer :free_min, :default => 0, :null => false
      t.decimal :amount, :precision => 8, :scale => 2
      t.string  :transaction_bid
      t.boolean :is_paid, :default => false, :null => false

      t.timestamps
    end

    add_index :call_charges, :tenant_id

  end
end
