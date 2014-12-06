class CreatePartnerLogos < ActiveRecord::Migration
  def change
    create_table :partner_logos do |t|
      t.integer :partner_master_id

      t.timestamps
    end
  end
end
