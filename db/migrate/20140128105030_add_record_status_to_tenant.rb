class AddRecordStatusToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :record_status, :string, :after => :record_call
  end
end
