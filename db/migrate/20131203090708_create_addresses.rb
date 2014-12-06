class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :tenant
      t.references  :locatable, polymorphic: true
      t.string  :timezone
      t.string  :street
      t.string  :suite
      t.string  :city
      t.string  :state
      t.string  :country
      t.string  :zip_code

      t.timestamps
    end
    add_index :addresses, :tenant_id
    add_index :addresses, [:locatable_id, :locatable_type]
  end
end
