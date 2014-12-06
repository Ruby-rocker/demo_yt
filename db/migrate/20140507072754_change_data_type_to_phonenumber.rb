class ChangeDataTypeToPhonenumber < ActiveRecord::Migration
  def up
  	change_column :partner_helps, :area_code, :string
  	change_column :partner_helps, :phone1, :string
  	change_column :partner_helps, :phone2, :string
  end

  def down
  	change_column :partner_helps, :area_code, :integer
  	change_column :partner_helps, :phone1, :integer
  	change_column :partner_helps, :phone2, :integer
  end
end
