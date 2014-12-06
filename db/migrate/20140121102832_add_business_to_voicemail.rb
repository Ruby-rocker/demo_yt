class AddBusinessToVoicemail < ActiveRecord::Migration
  def change
    add_column :voicemails, :business_id, :integer, after: :name
    add_column :phone_menus, :business_id, :integer, after: :name

    add_index :voicemails, :business_id
    add_index :phone_menus, :business_id
  end
end
