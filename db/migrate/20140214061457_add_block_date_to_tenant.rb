class AddBlockDateToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :block_date, :date
  end
end
