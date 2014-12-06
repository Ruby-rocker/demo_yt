module Partners::StatementsHelper
	
  def partner_statement_no_records
    concat content_tag(:section, class: 'table_row') {
      content_tag(:div, class: 'no_data') {
        content_tag(:div, 'No Records Found')
      }
    }
  end

end
