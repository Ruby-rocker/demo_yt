class AddFromAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :from_admin, :boolean, default: false, null: false, :after => :email
  end
end
