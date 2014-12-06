class CreateContactTags < ActiveRecord::Migration
  def change
    create_table :contact_tags do |t|
      t.references :tenant
      t.references :contact
      t.references :tag
      t.references :user

      t.timestamps
    end
    add_index :contact_tags, :tenant_id
    add_index :contact_tags, :contact_id
    add_index :contact_tags, :tag_id
    add_index :contact_tags, :user_id
  end
end
