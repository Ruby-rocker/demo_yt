class CreateRoleMasters < ActiveRecord::Migration
  def change
    create_table :role_masters do |t|
      t.string  :name
      t.string  :role_id, limit: 3, comment: 'Owner(1) Admin(2) staff(3) call_center(4)'
      t.timestamps
    end
  end
end
