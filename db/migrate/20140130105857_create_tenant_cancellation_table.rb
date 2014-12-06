class CreateTenantCancellationTable < ActiveRecord::Migration
  def up
  	create_table :tenant_cancellations do |t|
      t.references  :tenant
      t.text  :suggestion
      t.string  :reason_to_cancel
      t.text  :suggestion_to_cancel

      t.timestamps
    end
  end

  def down
  end
end
