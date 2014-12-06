class ChangeDataTypeOfEmailInEmailIds < ActiveRecord::Migration
  def change
  	change_column :email_ids, :emails, :string
  end
end
