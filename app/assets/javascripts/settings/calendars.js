function frm_validate_calendar_settings()
{
  $("#frm_save_calendar_settings").validate({
    rules: {
      "calendar[name]": {
        required: true,
        remote: {
          url: "/settings/calendars/check_duplicate_name",
          data: {calendar_id: $("#calendar_id").val()}
        }
      },
      "calendar[calendar_hours_attributes][0][start_time]": {
        required: true
      },
      "calendar[calendar_hours_attributes][0][close_time]": {
        required: true
      }
    },
    messages: {
      "calendar[name]":{
        required: "Please enter calendar name",
        remote: "Name already present"
      },
      "calendar[calendar_hours_attributes][0][start_time]": {
        required: "Required"
      },
      "calendar[calendar_hours_attributes][0][close_time]": {
        required: "Required"
      }
    }
  });
  $("input[id*=calendar_calendar_hours_attributes]").each(function() {
    $(this).rules("add", {
      required: true,
      messages: { required: "Required" }
    });
  });
}

function calendar_radio_button_selection(id, color_code){
	$('[id^='+id+']').closest("ul").find("a").attr("class", "")
	$('[id^='+id+']').closest("ul").find("input[type='radio']").attr("value", "")
  $('[id^='+id+']').find("input[type='radio']").attr('checked', 'checked');
	$('[id^='+id+']').find("input[type='radio']").val(color_code)
	$('[id^='+id+']').attr("class", "selected")
}

function add_appointment_detail()
{
  $.ajax({
    type: 'GET',
    dataType: 'script',
    url: '/settings/calendars/add_appointment_details',
    data: { 'count': ($('.appointmentWindow .index_count').last().val()) }
  });
}

function remove_appointment_detail(close){
  $.ajax({
    type: 'GET',
    dataType: 'script',
    url: '/settings/calendars/remove_calendar_hour',
    data: { calendar_hour_id: $(close).find("input").val() }
  });
  $(close).closest(".appointmentRow").fadeOut(500, function() { $(this).remove(); })
}