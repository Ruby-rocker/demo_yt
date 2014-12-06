class CreateBillingInfos < ActiveRecord::Migration
  def change
    create_table :billing_infos do |t|
      t.references :tenant
      t.string :first_name
      t.string :last_name
      t.string :customer_id # BrainTree
      t.string :email
      #----------- Credit Card ------------
      t.string :last_4, limit: 5
      t.string :card_type
      t.string :bin, limit: 10
      t.string :cardholder_name
      t.string :expiration_month
      t.string :expiration_year
      t.references :user

      t.timestamps
    end
    add_index :billing_infos, :tenant_id
    add_index :billing_infos, :user_id
  end
end
