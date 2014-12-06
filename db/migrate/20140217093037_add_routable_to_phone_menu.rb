class AddRoutableToPhoneMenu < ActiveRecord::Migration
  def change
    add_column :phone_menu_keys, :routable_type, :string, after: :digit
    add_column :phone_menu_keys, :routable_id, :integer, after: :digit
  end
end
