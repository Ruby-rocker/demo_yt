$(document).ready(function(){

  $("#appointment_recurring").change(function() {
    if($('#appointment_recurring').val() == "periodically")
    {
      $('#event_repeats').show();
      $('#periodically').show();
      $('#weekly').hide();
      $('#monthly').hide();
      $('#span_weekly').hide();
      $('#span_monthly').hide();
    }
    else if($('#appointment_recurring').val() == "weekly")
    {
      $('#event_repeats').show();
      $('#weekly').show();
      $('#periodically').hide();
      $('#monthly').hide();
      $('#span_weekly').show();
      $('#span_monthly').hide();
    }
    else if($('#appointment_recurring').val() == "monthly")
    {
      $('#event_repeats').show();
      $('#monthly').show();
      $('#weekly').hide();
      $('#periodically').hide();
      $('#span_weekly').hide();
      $('#span_monthly').show();
    }
    else
    {
      $('#event_repeats').hide();
      $('#periodically').hide();
      $('#weekly').hide();
      $('#monthly').hide();
      $('#span_weekly').hide();
      $('#span_monthly').hide();
    }
  });

  $.validator.addMethod("time", function (value, element) {
    return this.optional(element) || /^(0?[1-9]|1[012])(:[0-5]\d)[APap][mM]$/i.test(value);
  });

  $.validator.addMethod("multiemail", function (value, element) {
    if (this.optional(element)) {
      return true;
    }

    var emails = value.split(','),
      valid = true;

    for (var i = 0, limit = emails.length; i < limit; i++) {
      value = jQuery.trim(emails[i]);
      valid = valid && jQuery.validator.methods.email.call(this, value, element);
    }
    return valid;
  });

});

function getContact(contactId){
  jQuery.ajax({
    type: 'GET',
    url: 'get_contact_detail/'+contactId
  });
}

function chkEndonNever()
{
  if($("#ends_on_never").is(':checked'))
  {
    $("#ends_on_div").hide();
    $("#appointment_ends_on").val("");
  }
  else
  {
    $("#ends_on_div").show();
  }
}


function frm_validate_appointment()
{
  $(".frm_appointment").validate({
    rules: {
      "contact[first_name]":{
        required: true
      },
      "contact[last_name]":{
        required: true
      },
      "from_date": {
        required: true,
        date: true
      },
      "from_time": {
        required: true,
        time: true
      },
      "to_time": {
        required: true,
        time: true
      },
      "contact[phone_numbers_attributes][0][area_code]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][0][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][0][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      },
      "contact[phone_numbers_attributes][1][area_code]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][1][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][1][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      },
      "contact[phone_numbers_attributes][2][area_code]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][2][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][2][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      },
      "appointment[periodically]": {
        required: true,
        min: 1
      }
    },
    messages: {
      "contact[first_name]":{
        required: "Please enter contact first name"
      },
      "contact[last_name]":{
        required: "Please enter contact last name"
      },
      "from_date": {
        required: "Please select from date",
        date: "Please select a valid date."
      },
      "from_time": {
        required: "Please enter From-time",
        time: "Please enter a valid From-time."
      },
      "to_time": {
        required: "Please enter To-time",
        time: "Please enter a valid To-time."
      },
      "contact[phone_numbers_attributes][0][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][0][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][0][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "appointment[periodically]": {
        required: "Required",
        min: "Minimum 1 day"
      }
    }
  });
  $("input[id*=contact_email_ids_attributes]").each(function() {
    $(this).rules("add", {
      email: true,
      messages: { email: "Must be in 'test@example.com' format" }
    });
  });
  if ($('.frm_appointment').valid()){
    $.ajax({
    type: 'GET',
    url: '/appointments/is_valid_time',
    data: { from_date: $( "#from_date" ).val(), calendar_id: $( "#appointment_calendar_id" ).val(), id: $("#appointment_id").val(), to_time: $( "#to_time" ).val(), from_time: $( "#from_time" ).val()}
     })
    .done(function(result) {
      if (result == true){
        $('.frm_appointment').submit()
      }else{
        $(".app_availability_error").html("This time is not available for appointment. Please choose another time.")
        $("#from_time").focus()
      }
    })
  }
}