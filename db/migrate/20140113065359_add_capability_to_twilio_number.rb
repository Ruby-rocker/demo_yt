class AddCapabilityToTwilioNumber < ActiveRecord::Migration
  def change
    add_column :twilio_numbers, :capability, :string, after: :twilioable_type
  end
end
