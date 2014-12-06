class RenameColumnNameFromTypeToTypeOf < ActiveRecord::Migration
  def up
    rename_column :billing_transactions, :type, :type_of
  end

  def down
  end
end
