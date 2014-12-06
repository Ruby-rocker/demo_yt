class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.references  :tenant
      t.string      :name
      t.string      :area_code, limit: 4
      t.string      :phone1, limit: 4
      t.string      :phone2, limit: 5
      t.references  :callable, polymorphic: true

      t.timestamps
    end

    add_index :phone_numbers, :tenant_id
    add_index :phone_numbers, [:callable_id, :callable_type]

  end
end
