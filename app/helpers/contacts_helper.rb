module ContactsHelper
	def status_checkbox(status)
     link_to "javascript:;", class: "view_cal", id: "view_cal_#{status.id}", onclick: "submit_status_through_link(this)" do
       status.name
     end
 end
 def tag_checkbox(tag)
     link_to "javascript:;", class: "view_cal", id: "view_cal_#{tag.id}", onclick: "submit_tag_through_link(this)" do
       tag.name
     end
 end

end
