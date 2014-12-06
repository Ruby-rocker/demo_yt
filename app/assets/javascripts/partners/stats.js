$(document).ready(function() {
  $('#partner_state_records_search_date').on('change', function () {
    $.ajax({
      type: 'GET',
      dataType: 'script',
      cache: true,
      url: '/partners/stats/?partner_state_records_search[date]='+ $('#partner_state_records_search_date').val(),
      data: { 'partner_state_records_search[date_from]': $('#search_date_from').val(), 'partner_state_records_search[date_to]': $('#search_date_to').val() }
    }).done(function() {
    }); // end of inner ajax
  });
});

$(document).ajaxComplete(function(){
  $( "#custom_range_from" ).datepicker({
    dateFormat: "dd/mm/yy",
    onSelect: function( selectedDate ) {
      $( "#custom_range_to" ).datepicker( "option", "minDate", selectedDate );
      $('#search_date_from').val(selectedDate);
    }
  });
  $( "#custom_range_to" ).datepicker({
    dateFormat: "dd/mm/yy",
    onSelect: function( selectedDate ) {
      $( "#custom_range_from" ).datepicker( "option", "maxDate", selectedDate );
      $('#search_date_to').val(selectedDate);
    }
  });
});

function filter_custom_stats_range(){
  $("option[value='select']").remove();
  $('#partner_state_records_search_date').append("<option value='select'>Select</option>");
  $('#partner_state_records_search_date').val('select');
  $.fancybox.close();
  $('#partner_state_records_search_date').trigger("change");
}

function reset_custom_stats_range(){
  $.fancybox.close();
  $('#search_date_from').val('');
  $('#search_date_to').val('');
  $('#partner_state_records_search_date').trigger("change");
}