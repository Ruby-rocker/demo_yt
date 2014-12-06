class CreateCreditAmounts < ActiveRecord::Migration
  def change
    create_table :credit_amounts do |t|
      t.integer :tenant_id
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end
end
