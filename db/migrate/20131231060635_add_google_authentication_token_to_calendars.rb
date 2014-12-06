class AddGoogleAuthenticationTokenToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_authentication_token, :string
  end
end
