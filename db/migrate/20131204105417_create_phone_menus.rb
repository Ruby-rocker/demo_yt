class CreatePhoneMenus < ActiveRecord::Migration
  def change
    create_table :phone_menus do |t|
      t.references :tenant
      t.string :name
      t.string :status

      t.timestamps
    end
    add_index :phone_menus, :tenant_id
  end
end
