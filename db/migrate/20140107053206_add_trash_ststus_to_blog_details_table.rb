class AddTrashStstusToBlogDetailsTable < ActiveRecord::Migration
  def change
    add_column :blog_details, :trash_status, :boolean, default: 0
  end
end
