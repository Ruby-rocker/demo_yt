class CreateAddOnLogs < ActiveRecord::Migration
  def change
    create_table :add_on_logs do |t|
      t.references  :tenant
      t.references  :chargeable, polymorphic: true
      t.decimal     :amount, :precision => 8, :scale => 2
      t.date        :delete_date
      t.date        :start_date
      t.date        :end_date

      t.timestamps
    end

    add_index :add_on_logs, :tenant_id
    add_index :add_on_logs, [:chargeable_id, :chargeable_type]

  end
end
