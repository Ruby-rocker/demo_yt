class CreatePartnerStats < ActiveRecord::Migration
  def change
    create_table :partner_stats do |t|
      t.string :ip_address
      t.integer :partner_master_id
      t.integer :clicks

      t.timestamps
    end
  end
end
