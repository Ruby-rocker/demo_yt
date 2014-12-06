class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :tenant
      t.text :request
      t.text :suggestion
      t.references :reason_master
      t.references :user

      t.timestamps
    end
    add_index :feedbacks, :tenant_id
    add_index :feedbacks, :reason_master_id
    add_index :feedbacks, :user_id
  end
end
