class AddColumnsToHelp < ActiveRecord::Migration
  def change
    create_table :helps do |t|
      t.references  :tenant
      t.references  :user
      t.string :question
      t.text :details
      t.string :first_name
      t.string :last_name
      t.string :area_code
      t.string :phone1
      t.string :phone2
      t.string :email

      t.timestamps
    end

    add_index :helps, :tenant_id
    add_index :helps, :user_id
  end
end
