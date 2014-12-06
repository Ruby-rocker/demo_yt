class ChangeColumnTypeFromBooleanToInteger < ActiveRecord::Migration
  def up
  	change_column :blocked_timings, :status, :integer
  end

  def down
  	change_column :blocked_timings, :status, :boolean
  end
end
