class CreateCallDetails < ActiveRecord::Migration
  def change
    create_table :call_details do |t|
      t.references  :tenant
      t.references  :twilio_number

      #-------when call initiates----------
      t.string :account_sid, :null => false
      t.string :call_sid #, :null => false
      t.string :status
      t.string :call_to
      t.string :call_from
      t.string :direction
      t.string :from_city
      t.string :from_country
      t.string :from_state
      t.string :from_zip
      t.string :to_city
      t.string :to_country
      t.string :to_state
      t.string :to_zip

      #------from call api http://www.twilio.com/docs/api/rest/call -------------
      t.datetime :start_time
      t.datetime :end_time
      t.string   :duration
      t.string   :parent_call_sid
      t.datetime :date_created
      t.datetime :date_updated
      t.string   :phone_number_sid
      t.string   :price
      t.string   :price_unit
      t.string   :answered_by
      t.string   :forwarded_from
      t.string   :caller_name
      t.string   :group_sid

      t.timestamps
    end

    add_index :call_details, :tenant_id
    add_index :call_details, :twilio_number_id
    add_index :call_details, :call_sid
    add_index :call_details, :phone_number_sid
    add_index :call_details, :parent_call_sid

  end
end
