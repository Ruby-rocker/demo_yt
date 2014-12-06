class CreateVoicemails < ActiveRecord::Migration
  def change
    create_table :voicemails do |t|
      t.references :tenant
      t.string :name
      t.string :status
      t.boolean :transcribe, default: false, null: false

      t.timestamps
    end
    add_index :voicemails, :tenant_id
  end
end
