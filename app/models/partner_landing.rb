class PartnerLanding < ActiveRecord::Base
  attr_accessible :content, :partner_master_id
  belongs_to :partner_master
end
