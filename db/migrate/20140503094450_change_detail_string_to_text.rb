class ChangeDetailStringToText < ActiveRecord::Migration
   def up
  	change_column :partner_helps, :details, :text
  end

  def down
  	change_column :partner_helps, :details, :string
  end
end
