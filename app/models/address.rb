class Address < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to  :locatable, polymorphic: true
  attr_protected :tenant_id
  #validates :city, :tenant_id, :street, :zip_code, :state, :country, presence: true

  def new_setup(params)
  	self.street = params[:billing_street]
  	self.city = params[:billing_city]
  	self.state = params[:billing_state]
  	self.zip_code = params[:billing_zip]
  	self.country = params[:billing_country]
  	self.suite = params[:billing_floor]
  	self
  end
end
