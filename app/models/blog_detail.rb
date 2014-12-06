class BlogDetail < ActiveRecord::Base
  attr_accessible :title, :description, :blog_url, :image_url, :post_modified, :post_id, :post_status, :trash_status
end
