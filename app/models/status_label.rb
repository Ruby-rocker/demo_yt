class StatusLabel < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  attr_accessible :color, :name
  # validates :name, presence: true
  # validates :color, presence: true

  belongs_to :tenant
  has_one   :contacts

  def delete_label!
  	if Contact.find_by_status_label_id(id).present?
  		false
  	else
  		self.destroy
  		true
  	end  	
  end
  
end
