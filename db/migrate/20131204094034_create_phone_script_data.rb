class CreatePhoneScriptData < ActiveRecord::Migration
  def change
    create_table :phone_script_data do |t|
      t.references :tenant
      t.references :phone_script
      t.string :data_key
      t.string :data_value

      t.timestamps
    end
    add_index :phone_script_data, :tenant_id
    add_index :phone_script_data, :phone_script_id
  end
end
