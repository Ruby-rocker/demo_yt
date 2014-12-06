class CreateBlockedTimings < ActiveRecord::Migration
  def change
    create_table :blocked_timings do |t|
      t.integer :tenant_id
      t.integer :calendar_id
      t.string :appt_time
      t.string :appt_date
      t.boolean :status, :default => true

      t.timestamps
    end
  end
end
