class CreateDiscountMasters < ActiveRecord::Migration
  def change
    create_table :discount_masters do |t|
      t.string      :coupon_code
      t.decimal     :amount, :precision => 8, :scale => 2
      t.decimal     :percentage, :precision => 5, :scale => 2
      t.references  :partner
      t.boolean     :active, :default => true, :null => false
      t.string      :duration
      t.text        :notes

      t.timestamps
    end
    add_index :discount_masters, :partner_id
  end
end
