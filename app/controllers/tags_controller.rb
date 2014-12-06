class TagsController < ApplicationController
	def index
	  	@tags = Tag.where("name like ?", "%#{params[:q]}%")
	  	results = @tags.map(&:attributes)
	    respond_to do |format|	      
	      format.json { render :json => results }
	    end
	end
end
