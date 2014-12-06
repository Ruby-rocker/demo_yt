class Feedback < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :reason_master
  belongs_to :user
  attr_accessible :request, :suggestion
end
