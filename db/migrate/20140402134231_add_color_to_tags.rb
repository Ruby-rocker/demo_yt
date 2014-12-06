class AddColorToTags < ActiveRecord::Migration
  def change
    add_column :tags, :color, :string
  end
end
