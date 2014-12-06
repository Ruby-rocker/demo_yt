class AddRecordCallToCallDetail < ActiveRecord::Migration
  def change
    add_column :call_details, :record_call, :boolean, default: false, null: false, after: :twilio_number_id
    add_column :tenants, :record_call, :boolean, default: false, null: false, after: :plan_bid
  end
end
