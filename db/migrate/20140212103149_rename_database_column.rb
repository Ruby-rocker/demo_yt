class RenameDatabaseColumn < ActiveRecord::Migration
  def up
  	rename_column :discount_masters, :partner_id, :partner_master_id
  end

  def down
  	rename_column :discount_masters, :partner_id, :partner_master_id
  end
end
