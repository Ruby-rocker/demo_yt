class CreateEmailIds < ActiveRecord::Migration
  def change
    create_table :email_ids do |t|
      t.references :tenant
      t.references :mailable, polymorphic: true
      t.text :emails

      t.timestamps
    end
    add_index :email_ids, :tenant_id
    add_index :email_ids, [:mailable_id, :mailable_type]
  end
end
