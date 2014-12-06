class CreateStatusLabels < ActiveRecord::Migration
  def change
    create_table :status_labels do |t|
      t.references :tenant
      t.string :name
      t.string :color

      t.timestamps
    end
    add_index :status_labels, :tenant_id
  end
end
