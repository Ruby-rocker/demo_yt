class RenameColumnNameFromTypeToHoursType < ActiveRecord::Migration
  def up
  	rename_column :calendar_hours, :type, :hours_type
  end

  def down
  end
end
