module Partners::StatsHelper
	def partner_state_no_records
    haml_tag :table do
      haml_tag :tr do
        haml_tag :td, {:class => 'cell'} do
          haml_tag :td do
            haml_concat "No Record Found"
          end
        end
    end
  end
  end
end
