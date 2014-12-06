class AddIsHeardToRecordings < ActiveRecord::Migration
  def change
    add_column :recordings, :is_heard, :boolean, default: false, null: false, :after => :tenant_id
  end
end
