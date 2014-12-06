class CreateCalendarHours < ActiveRecord::Migration
  def change
    create_table :calendar_hours do |t|
      t.references :tenant
      t.references :calendar
      t.string :type
      t.string :week_days
      t.string :start_time
      t.string :close_time

      t.timestamps
    end
    add_index :calendar_hours, :tenant_id
    add_index :calendar_hours, :calendar_id
  end
end
