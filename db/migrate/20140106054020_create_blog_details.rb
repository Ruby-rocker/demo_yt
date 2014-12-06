class CreateBlogDetails < ActiveRecord::Migration
  def change
    create_table :blog_details do |t|
    	t.string :title
      t.text :description
      t.string :blog_url
      t.string :image_url
      t.date :post_modified
      t.integer :post_id
      t.boolean :post_status

      t.timestamps
    end
  end
end
