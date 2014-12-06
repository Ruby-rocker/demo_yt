class AddIsPaidToBonus < ActiveRecord::Migration
  def change
    add_column :bonus, :is_paid, :boolean
  end
end
