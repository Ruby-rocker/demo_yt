class CreatePhoneScriptHours < ActiveRecord::Migration
  def change
    create_table :phone_script_hours do |t|
      t.references :tenant
      t.references :phone_script
      t.string :first_mon
      t.string :first_tue
      t.string :first_wed
      t.string :first_thu
      t.string :first_fri
      t.string :first_sat
      t.string :first_sun
      t.string :second_mon
      t.string :second_tue
      t.string :second_wed
      t.string :second_thu
      t.string :second_fri
      t.string :second_sat
      t.string :second_sun
      t.string :day_status
      t.boolean :during_hours_call_center, :default => true, :null => false
      t.boolean :after_hours_call_center, :default => true, :null => false

      t.timestamps
    end
    add_index :phone_script_hours, :tenant_id
    add_index :phone_script_hours, :phone_script_id
  end
end

