class CreatePhoneScriptCalls < ActiveRecord::Migration
  def change
    create_table :phone_script_calls do |t|
      t.references :tenant
      t.string :campaign_id   # from call center
      t.string :talk_time
      t.string :hold_time
      t.datetime :call_time
      t.boolean :is_paid, :default => false, :null => false
      t.string :name
      t.string :xps_phone   # from call center
      t.string :disposition   # from call center
      t.string :agent_name

      t.timestamps
    end
    add_index :phone_script_calls, :tenant_id

    add_column :call_details, :callable_type, :string, after: :twilio_number_id
    add_column :call_details, :callable_id, :integer, after: :twilio_number_id
    remove_column :call_details, :twilio_number_id
  end
end
