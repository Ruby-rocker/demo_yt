$(document).ready(function() {
    $($('#business_address_attributes_country')).change(function() {
        if($('#business_address_attributes_country').val() == ('US')){
            $('.us_states').show();
            $('.ca_states').hide();
            $('.ca_states').val('');
            $('.other_states').hide();
            $('.other_states').val('');
        }
        else if($('#business_address_attributes_country').val() == ('CA')){
            $('.us_states').hide();
            $('.us_states').val('');
            $('.ca_states').show();
            $('.other_states').hide();
            $('.other_states').val('');
        }
        else {
            $('.us_states').hide();
            $('.us_states').val('');
            $('.ca_states').hide();
            $('.ca_states').val('');
            $('.other_states').show();
        }
    });

  if($(".business_info_form"))
  {
    $("#frm_save_business").validate({
      rules: {
        "business[name]":{
          required: true,
          minlength: 3,
          remote: {
            url: "/settings/businesses/check_business_name",
            data: { "business_id": $("#business_id").val()}
          }
        },
        "business[address_attributes][country]":{
          required: true
        },
        "business[address_attributes][street]":{
          required: true
        },
        "business[address_attributes][city]":{
          required: true
        },
//        "business[address_attributes][state]":{
//          required: true
//        },
        "us_state":{
            required: true
        },
        "ca_state":{
            required: true
        },
        "other_state":{
            required: true
        },
        "business[address_attributes][zip_code]":{
          required: true,
          minlength: 5,
          maxlength: 7,
          number: {
              depends: function(element) {
                  if($("#business_address_attributes_country").val() == 'US') {
                      return true;
                  }
                  else if($("#business_address_attributes_country").val() == 'CA'){
                      return false;
                  }
              }
          }
        },
        "business[address_attributes][timezone]":{
          required: true
        },
        "business[phone_number_attributes][area_code]":{
          required: true,
          number: true,
          minlength: 3,
          maxlength: 3
        },
        "business[phone_number_attributes][phone1]":{
          required: true,
          number: true,
          minlength: 3,
          maxlength: 3
        },
        "business[phone_number_attributes][phone2]":{
          required: true,
          number: true,
          minlength: 4,
          maxlength: 4
        }
      },
      messages: {
        "business[name]":{
          required: "Please enter business name",
          minlength: "Min Length is 3 characters",
          remote: "Business with same name available. Please enter another name."
        },
        "business[address_attributes][country]":{
          required: "Please select country"
        },
        "business[address_attributes][street]":{
          required: "Please enter street"
        },
        "business[address_attributes][city]":{
          required: "Please enter city"
        },
//        "business[address_attributes][state]":{
//          required: "Please select state/province"
//        },
        "us_state":{
            required: "Required state/province"
        },
        "ca_state":{
            required: "Required state/province"
        },
        "other_state":{
            required: "Required state/province"
        },
        "business[address_attributes][zip_code]":{
          required: "Please enter zip code"
        },
        "business[address_attributes][time_zone]":{
          required: "Please select timezone"
        },
        "business[phone_number_attributes][area_code]":{
          required: "required"
        },
        "business[phone_number_attributes][phone1]":{
          required: "required"
        },
        "business[phone_number_attributes][phone2]":{
          required: "required"
        }
      }
    });
  }
});