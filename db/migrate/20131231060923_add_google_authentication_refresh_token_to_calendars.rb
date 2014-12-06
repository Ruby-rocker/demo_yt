class AddGoogleAuthenticationRefreshTokenToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_authentication_refresh_token, :string
  end
end
