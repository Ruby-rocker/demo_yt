class AddBusinessIdToCalendar < ActiveRecord::Migration
  def change
    add_column :calendars, :business_id, :integer
  end
end
