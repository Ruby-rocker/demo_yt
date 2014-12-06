class ChangeSubdomainAllowNullInUsers < ActiveRecord::Migration
  def change
  	change_column :users, :subdomain, :string, :null => true
  end
end
