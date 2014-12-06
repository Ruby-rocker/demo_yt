class CreatePartnerLandings < ActiveRecord::Migration
  def change
    create_table :partner_landings do |t|
      t.integer :partner_master_id
      t.text :content

      t.timestamps
    end
  end
end
