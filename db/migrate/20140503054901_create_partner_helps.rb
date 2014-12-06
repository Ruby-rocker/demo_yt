class CreatePartnerHelps < ActiveRecord::Migration
  def change
    create_table :partner_helps do |t|
      t.integer :tenant_id
      t.integer :user_id
      t.string :details
      t.string :first_name
      t.string :last_name
      t.integer :area_code
      t.integer :phone1
      t.integer :phone2
      t.string :email

      t.timestamps
    end
  end
end
