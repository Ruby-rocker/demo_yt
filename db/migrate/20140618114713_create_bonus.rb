class CreateBonus < ActiveRecord::Migration
  def change
    create_table :bonus do |t|
      t.integer :partner_master_id
      t.integer :bonus

      t.timestamps
    end
  end
end
