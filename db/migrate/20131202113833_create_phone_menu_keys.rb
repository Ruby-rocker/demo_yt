class CreatePhoneMenuKeys < ActiveRecord::Migration
  def change
    create_table :phone_menu_keys do |t|
      t.references  :tenant
      t.references  :phone_menu
      t.string      :digit, limit: 4 # only 4 chars will be saved

      t.timestamps
    end

    add_index :phone_menu_keys, :tenant_id
    add_index :phone_menu_keys, :phone_menu_id

  end
end
