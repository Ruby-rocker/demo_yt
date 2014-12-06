class RenameColumnType < ActiveRecord::Migration
  def change
    rename_column :partner_payment_informations, :type, :payment_type
  end
end
