class CreatePartnerStatements < ActiveRecord::Migration
  def change
    create_table :partner_statements do |t|

      t.timestamps
    end
  end
end
