class AddProratedToAddOnLogs < ActiveRecord::Migration
  def change
    add_column :add_on_logs, :prorated, :boolean, default: false, null: false, after: :end_date
    change_column :add_on_logs, :delete_date, :datetime
    rename_column :add_on_logs, :delete_date, :deleted_at
  end
end
