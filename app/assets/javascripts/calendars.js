$(document).ready(function(){
	$("#appointment_search_date").datepicker();
  $('#cancel_google_sync').click(function(){
      $( "#dialog-confirm" ).dialog({
          resizable: false,
          height:200,
          modal: true,
          buttons: {
              "Yes, cancel sync": function() {
                  window.location.href = '/cancel_google_sync?state=#{calendar_id}';
              },
              "No, keep sync": function() {
                  $( this ).dialog( "close" );
              }
          }
      });
  });
});

function select_view(current){
	$.ajax({
      type: 'POST',
      url: '/calendars/appointment_view',
      data: {view_type: $(current).val()}
    })
}

function set_appointment_timing(day_format, current){
	$(".calendarView table").find("a").removeClass("active")
	$(current).addClass("active")
	$(".availableapptView h2 span").first().text(day_format)
}

function set_availability(appt_date, appt_time, class_name){
	$.ajax({
      type: 'GET',
      url: '/calendars/block_timing_modification',
      data: {appt_date: appt_date, appt_time: appt_time, calendar_id: $("#calendar_id").val(), status_class: $(class_name).attr("class")},
      success: function (dataCheck) {
                if ($(class_name).attr("class") == 'active') {
                    $(class_name).attr("class", "")
                    $(class_name).find("i img").attr("src", "/assets/btn_plus@2x.png")
                }
                else{
                	$(class_name).attr("class", "active")
                    $(class_name).find("i img").attr("src", "/assets/btn_close@2x.png")
                }
            }
    })

}

function submit_for_appointments(){
  $("#calendar_form").submit()
}

function select_all_calendar(){
  $(".calendar_selector").prop('checked', true)
  submit_for_appointments()
}

function submit_through_link(link_element){
  $(link_element).parent().find("input").prop('checked', true)
  submit_for_appointments()
}