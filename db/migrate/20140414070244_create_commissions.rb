class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.integer :user_id
      t.integer :partner_master_id
      t.decimal :commission
      t.boolean :is_paid

      t.timestamps
    end
  end
end
