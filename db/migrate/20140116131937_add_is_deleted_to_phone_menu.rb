class AddIsDeletedToPhoneMenu < ActiveRecord::Migration
  def change
    add_column :phone_menus, :is_deleted, :boolean, default: false, null: false, after: :status
    add_column :voicemails, :is_deleted, :boolean, default: false, null: false, after: :status
  end
end
