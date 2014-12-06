class AddTotalTimeToPhoneScriptCalls < ActiveRecord::Migration
  def change
    add_column :phone_script_calls, :total_time, :integer, default: 0, null: false, after: :campaign_id
  end
end
