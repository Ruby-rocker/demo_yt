class CreatePartnerPaymentInformations < ActiveRecord::Migration
  def change
    create_table :partner_payment_informations do |t|
      t.integer :partner_master_id
      t.string :paypal_email
      t.string :ssn
      t.string :type

      t.timestamps
    end
  end
end
