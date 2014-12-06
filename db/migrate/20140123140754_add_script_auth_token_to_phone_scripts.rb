class AddScriptAuthTokenToPhoneScripts < ActiveRecord::Migration
  def change
    add_column :phone_scripts, :script_auth_token, :string
  end
end
