$(document).ready(function() {
    $('ul.dateRange').on('change', '#search_date', function () {
        $.ajax({
            type: 'GET',
            dataType: 'script',
            cache: true,
            url: '/?search[date]='+ $('#search_date').val(),
          data: { 'search[date_from]': $('#search_date_from').val(), 'search[date_to]': $('#search_date_to').val() }
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

function filter_custom_range(){
  $('#search_date').append("<option value='select'>Select</option>");
  $('#search_date').val('select');
  $.fancybox.close();
  $('#search_date').trigger("change");
}

function reset_custom_range(){
  $.fancybox.close();
  $('#search_date_from').val('');
  $('#search_date_to').val('');
  $('#search_date').trigger("change");
}