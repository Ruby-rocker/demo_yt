class AddCalendarAuthTokenToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :calendar_auth_token, :string
  end
end
