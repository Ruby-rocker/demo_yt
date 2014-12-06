class AddGoogleAuthenticationEmailToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_authentication_email, :string
  end
end
