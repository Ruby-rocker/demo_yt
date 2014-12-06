ActiveAdmin.register Business do
  menu :priority => 5
  actions :all, :except => [:destroy, :new, :edit]
  filter :name
  filter :website
  
  index do
    column :name
    column :website
    column :description
    column :landmark
    default_actions
  end

  show :title => "Show Business" do |ad|
    attributes_table do
      row :id
      row :name
      row :website
      row :description
      row :landmark
      row :created_at
      row :updated_at
    end
  end

 #  form :partial => "admin/businesses/form"
 #  controller do
 #  	def new
 #    	@business = Business.new
 #   	end
  
 #   	def create
 #    	@business = Business.new(params[:business])
 #    	respond_to do |format|
 #      	if @business.save!
 #        	format.html { redirect_to businesses_path, notice: "Business saved successfully" }
	#       else
 #  	      format.html { render action: "new" }
 #    	  end
 #    	end
 #   	end

 #   	def edit
 #      @business = Business.find(params[:id])
 #    end
    
 #    def update
 #      @business = Business.find(params[:id])
 #      respond_to do |format|
 #        if @business.update_attributes!(params[:business])
 #          format.html { redirect_to businesses_path, notice: "Business saved successfully" }
 #        else
 #          format.html { render action: "edit" }
 #        end
 #      end
 #    end
	# end
end
