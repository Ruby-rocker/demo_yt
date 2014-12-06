class ReasonMaster < ActiveRecord::Base
  attr_accessible :reason
  has_many :feedbacks
  has_many :tenant_cancellations
end
