class CreateTwilioNumbers < ActiveRecord::Migration
  def change
    create_table :twilio_numbers do |t|
      t.references  :tenant
      t.string     :phone_line
      t.string     :friendly_name
      t.string     :iso_country
      t.boolean    :toll_free, :default => false, :null => false
      t.references  :twilioable, polymorphic: true
      t.string     :phone_sid, :unique => true
      t.string     :account_sid

      t.timestamps
    end

    add_index :twilio_numbers, :tenant_id
    add_index :twilio_numbers, [:twilioable_id, :twilioable_type]
    add_index :twilio_numbers, :phone_sid, :unique => true
    add_index :twilio_numbers, :account_sid

  end
end
