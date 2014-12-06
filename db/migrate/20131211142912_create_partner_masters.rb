class CreatePartnerMasters < ActiveRecord::Migration
  def change
    create_table :partner_masters do |t|
      t.string :name
      t.string :email
      t.text :notes

      t.timestamps
    end
  end
end
