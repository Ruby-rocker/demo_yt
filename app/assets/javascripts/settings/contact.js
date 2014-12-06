function remove_raw_contacts_settings(close, id){
  $(close).closest(".rowWrap").fadeOut(500, function() { $(this).remove(); })
}
function remove_raw_tag_contacts_settings(close, id){
	$(close).closest(".rowWrap").fadeOut(500, function() { $(this).remove(); })
      $.ajax({
        type: 'DELETE',
        dataType: 'script',
        url: '/settings/contacts/'+id,
        data: {
          authenticity_token: authToken()
        }
      });
}
function remove_raw_status_contacts_settings(close, id){
  $(close).closest(".rowWrap").fadeOut(500, function() { $(this).remove(); })
      $.ajax({
        type: 'GET',
        dataType: 'script',
        url: '/settings/contacts/delete_status/'+id,
        data: {
          authenticity_token: authToken()
        }
      });
}
function radio_button_selection(id, color_code){
	$('[id^='+id+']').closest("ul").find("a").attr("class", "")
	$('[id^='+id+']').closest("ul").find("input:hidden").attr("value", "")
	$('[id^='+id+']').next().val(color_code)
	$('[id^='+id+']').attr("class", "selected")
}

function frm_validate_contact_settings(){
  
  $("#frm_save_contact_settings").validate({

    rules: {
      "contact_csv":{
        extension: "csv"
      },
      "status[st_name][]":{
        required: true
      },
      "tag[name][]":{
        required: true
      }
    },
    messages: {
      "contact_csv":{
        extension: "Only CSV format of file is allowed",
      },
      "status[st_name][]":{
        required: "Please enter status label name"
      },
      "tag[name][]":{
        required: "Please enter tag name"
      }
    }
   
  });
}