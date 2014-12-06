class AddShowOn < ActiveRecord::Migration
  def change
    add_column :add_on_logs, :show_on, :date, after: :prorated
  end
end
