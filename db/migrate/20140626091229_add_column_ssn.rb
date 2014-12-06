class AddColumnSsn < ActiveRecord::Migration
  def change
    add_column :partner_payment_informations, :ssn_for_non_us, :string
  end
end
