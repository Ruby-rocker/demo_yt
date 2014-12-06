class ChangeDigitInPhoneMunuKey < ActiveRecord::Migration
  def change
    change_column :phone_menu_keys, :digit, :string, limit: 6
  end
end
