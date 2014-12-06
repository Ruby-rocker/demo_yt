class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :tenant
      t.string :name

      t.timestamps
    end
    add_index :tags, :tenant_id
  end
end
