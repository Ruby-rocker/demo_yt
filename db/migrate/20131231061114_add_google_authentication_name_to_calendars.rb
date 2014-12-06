class AddGoogleAuthenticationNameToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_authentication_name, :string
  end
end
