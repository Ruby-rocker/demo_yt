$(document).ready(function() {
  $('ul.dateRange').on('change', '#call_records_search_date', function () {
    $.ajax({
      type: 'GET',
      dataType: 'script',
      cache: true,
      url: 'call_recordings/?call_records_search[date]='+ $('#call_records_search_date').val(),
      data: { 'call_records_search[date_from]': $('#call_records_search_date_from').val(), 'call_records_search[date_to]': $('#call_records_search_date_to').val() }
    }).done(function() {
    }); // end of inner ajax
  });

  $('ul.actionType').on('change', '#call_record_search_phone_script', function () {
      $.ajax({
        type: 'GET',
        dataType: 'script',
        cache: true,
        url: 'call_recordings/?call_records_search[phone_script]='+ $('#call_record_search_phone_script').val(),
        data: { 'call_records_search[phone_script_to]': $('#call_records_search_phone_script_from').val(), 'call_records_search[phone_script_to]': $('#call_records_search_phone_script_to').val() }
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

function filter_custom_date_range(){
  $('#call_records_search_date').append("<option value='select'>Select</option>");
  $('#call_records_search_date').val('select');
  $.fancybox.close();
  $('#call_records_search_date').trigger("change");
}

function reset_custom_date_range(){
  $.fancybox.close();
  $('#call_records_search_date_from').val('');
  $('#call_records_search_date_to').val('');
  $('#call_records_search_date').trigger("change");
}