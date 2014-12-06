class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.references  :tenant

      t.string :recording_sid, :null => false
      t.string :duration
      t.string :call_sid #, :null => false
      t.datetime :date_created
      t.datetime :date_updated
      t.text :url
      t.string :account_sid, :null => false


      t.timestamps
    end

    add_index :recordings, :tenant_id
    add_index :recordings, :recording_sid
    add_index :recordings, :call_sid

  end
end
