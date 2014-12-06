class PartnerHelp < ActiveRecord::Base
  attr_accessible :question, :area_code, :details, :email, :first_name, :last_name, :phone1, :phone2, :partner_master_id
end
