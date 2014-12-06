$(document).ready(function() {
    $($('#billing_info_address_attributes_country')).change(function() {
        if($('#billing_info_address_attributes_country').val() == ('US')){
            $('.us_states').show();
            $('.ca_states').hide();
            $('.ca_states').val('');
            $('.other_states').hide();
            $('.other_states').val('');
        }
        else if($('#billing_info_address_attributes_country').val() == ('CA')){
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

    $("#frm_update_billing_info").validate({
        rules: {
            "billing_info[first_name]":{
                required: true
            },
            "billing_info[last_name]":{
                required: true
            },
            "billing_info[email]":{
                required: true,
                email: true
            },
            "billing_info[address_attributes][country]":{
                required: true
            },
            "billing_info[address_attributes][street]":{
                required: true
            },
//            "billing_info[address_attributes][suite]":{
//                required: true
//            },
            "billing_info[address_attributes][city]":{
                required: true
            },
            "us_state":{
                required: true
            },
            "ca_state":{
                required: true
            },
            "other_state":{
                required: true
            },
            "billing_info[address_attributes][zip_code]":{
                required: true,
                minlength: 5,
                maxlength: 7,
                number: {
                    depends: function(element) {
                        if($("#billing_info_address_attributes_country").val() == 'US') {
                            return true;
                        }
                        else if($("#billing_info_address_attributes_country").val() == 'CA'){
                            return false;
                        }
                    }
                }
            },
            "billing_info[phone_number_attributes][area_code]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "billing_info[phone_number_attributes][phone1]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "billing_info[phone_number_attributes][phone2]":{
                required: true,
                number: true,
                minlength: 4,
                maxlength: 4
            },
//            "billing_info[card_type]": {
//                required: true
//            },
            "last_4":{
                required: {
                    depends: function(element) {
                        if ($("#last_4").val()) { return true; } else { return false; }
                    }
                },
                number: true,
                minlength: 12,
                maxlength: 19
            },
            "ccv":{
                required: {
                    depends: function(element) {
                        if ($('#ccv').val()) { return true; } else { return false; }
                    }
                },
                number: true,
                minlength: 3,
                maxlength: 4
            }
//            "billing_info[expiration_month]":{
//                required: true
//            },
//            "billing_info[expiration_year]":{
//                required: true
//            },
//            "billing_info[cardholder_name]":{
//                required: true
//            }
        },
        messages: {
            "billing_info[first_name]":{
                required: "Please enter first name"
            },
            "billing_info[last_name]":{
                required: "Please enter last name"
            },
            "billing_info[email]":{
                required: "Please enter email",
                email: "Please enter a valid email address"
            },
            "billing_info[address_attributes][country]":{
                required: "Please select country"
            },
            "billing_info[address_attributes][street]":{
                required: "Please enter street"
            },
//            "billing_info[address_attributes][suite]":{
//                required: "Please enter suite"
//            },
            "billing_info[address_attributes][city]":{
                required: "Please enter city"
            },
            "us_state":{
                required: "Required state/province"
            },
            "ca_state":{
                required: "Required state/province"
            },
            "other_state":{
                required: "Required state/province"
            },
            "billing_info[address_attributes][zip_code]":{
                required: "Please enter zip code"
            },
            "billing_info[phone_number_attributes][area_code]":{
                required: "required"
            },
            "billing_info[phone_number_attributes][phone1]":{
                required: "required"
            },
            "billing_info[phone_number_attributes][phone2]":{
                required: "required"
            },
//            "billing_info[card_type]": {
//                required: "Please select card type"
//            },
            "billing_info[last_4]":{
                required: "Please enter card number"
            },
            "ccv":{
                required: "Please enter CCV"
            }
//            "billing_info[expiration_month]":{
//                required: "Please select expiration month"
//            },
//            "billing_info[expiration_year]":{
//                required: "Please select expiration year"
//            },
//            "billing_info[cardholder_name]":{
//                required: "Please enter name on card"
//            }
        }
    });
});