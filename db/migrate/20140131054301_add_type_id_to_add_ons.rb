class AddTypeIdToAddOns < ActiveRecord::Migration
  def change
    add_column :add_ons, :type_id, :integer, after: :type_of
  end
end
