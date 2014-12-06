class AddNextDueToCallCharges < ActiveRecord::Migration
  def change
    add_column :call_charges, :next_due, :date, :after => :amount
  end
end
