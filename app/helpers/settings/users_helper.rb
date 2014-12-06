module Settings::UsersHelper
	def reasons_list
		ReasonMaster.all.collect {|r| [r.reason, r.id]}
	end

	def display_status
		@tenant_cancellation.other_reason ? "display: block;" : "display: none;"
	end
end
