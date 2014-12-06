class RenameIsPaidInPhoneScriptCalls < ActiveRecord::Migration
  def change
    rename_column :phone_script_calls, :is_paid, :is_read
  end
end
