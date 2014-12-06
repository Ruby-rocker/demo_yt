class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.references :tenant
      t.string :name
      t.string :website
      t.text :description
      t.text :landmark

      t.timestamps
    end
    add_index :businesses, :tenant_id
  end
end
