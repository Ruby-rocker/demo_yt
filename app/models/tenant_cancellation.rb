class TenantCancellation < ActiveRecord::Base
	acts_as_tenant(:tenant)

	belongs_to :tenant
	attr_protected :tenant_id
	belongs_to :reason_master

	before_save :check_reason

	def check_reason
		self.other_reason = (reason? ? other_reason : nil)
	end

  def reason?
  	reason_master_id.eql?(5)
  end
end