class AddRetryIdToCallCharges < ActiveRecord::Migration
  def change
    add_column :call_charges, :retry_id, :integer, after: :is_paid

    add_index :call_charges, :retry_id
  end
end
