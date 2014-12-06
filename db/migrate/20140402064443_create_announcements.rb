class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.text :message
      t.boolean :via_email
      t.boolean :via_sms
      t.integer :user_id

      t.timestamps
    end
  end
end
