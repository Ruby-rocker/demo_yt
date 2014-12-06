$(document).ready(function() {
  $('ul.dateRange').on('change', '#voicemail_records_search_date', function () {
    $.ajax({
      type: 'GET',
      dataType: 'script',
      cache: true,
      url: 'voicemail/?voicemail_records_search[date]='+ $('#voicemail_records_search_date').val(),
      data: { 'voicemail_records_search[date_from]': $('#search_date_from').val(), 'voicemail_records_search[date_to]': $('#search_date_to').val() }
    }).done(function() {
    }); // end of inner ajax
  });

  $('ul.actionType').on('change', '#call_record_search_voicemail', function () {
      $.ajax({
        type: 'GET',
        dataType: 'script',
        cache: true,
        url: 'voicemail/?voicemail_records_search[phone_script]='+ $('#call_record_search_voicemail').val(),
        data: { 'voicemail_records_search[phone_script_to]': $('#call_record_search_voicemail_from').val(), 'voicemail_records_search[phone_script_to]': $('#call_records_search_voicemail_to').val() }
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

function filter_custom_voicemail_range(){
  $("option[value='select']").remove();
  $('#voicemail_records_search_date').append("<option value='select'>Select</option>");
  $('#voicemail_records_search_date').val('select');
  $.fancybox.close();
  $('#voicemail_records_search_date').trigger("change");
}

function reset_custom_voicemail_range(){
  $.fancybox.close();
  $('#search_date_from').val('');
  $('#search_date_to').val('');
  $('#voicemail_records_search_date').trigger("change");
}