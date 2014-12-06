class RemoveSessionTable < ActiveRecord::Migration
  def up
  	drop_table :sessions
  end

  def down
  end
end
