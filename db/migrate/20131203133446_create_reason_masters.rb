class CreateReasonMasters < ActiveRecord::Migration
  def change
    create_table :reason_masters do |t|
      t.text :reason

      t.timestamps
    end
  end
end
