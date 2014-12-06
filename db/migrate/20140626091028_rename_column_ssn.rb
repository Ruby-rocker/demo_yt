class RenameColumnSsn < ActiveRecord::Migration
  def change
  	 rename_column :partner_payment_informations, :ssn, :ssn_for_us
  end
end
