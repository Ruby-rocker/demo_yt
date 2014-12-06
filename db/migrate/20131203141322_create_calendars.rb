class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.references :tenant
      t.string :name
      t.string :color
      t.string :timezone
      t.string :apt_length, limit: 4

      t.timestamps
    end
    add_index :calendars, :tenant_id
  end
end
