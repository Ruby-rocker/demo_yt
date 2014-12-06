module Api
  module V1
    class BlogDetailsController < ApplicationController
    	respond_to :json
      skip_before_filter :logged_in, :set_defaults, :set_current_tenant

    	def fetch_blog_details
        post_ids = params[:post_id].split(",") if params[:post_id]
    		blog_details = BlogDetail.find_all_by_post_id(post_ids) if params[:post_id]
        (params[:post_status] = (params[:post_status] == 'publish' ? true : false)) if params[:post_status]
        (params[:trash_status] = (params[:trash_status] == 'trash' ? true : false)) if params[:trash_status]
    		if blog_details.present?
          blog_details.each_with_index do |blog, index|
            params[:post_id] = post_ids[index]
    			  blog.update_attributes(params)
          end
    		else
    			blog_detail = BlogDetail.new(params)
    			result = blog_detail.save!
    		end
    		render json: {success: result}
    	end

      def delete_blog_detail
        render json: {success: BlogDetail.find_all_by_post_id(params[:post_id].split(",")).map{|blog| blog.destroy} }
      end
    end
	end
end