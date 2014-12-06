$(document).ready(function() {
    $($('#partner_master_address_attributes_country')).change(function() {
        if($('#partner_master_address_attributes_country').val() == ('US')){
            $('.us_states').show();
            $('.ca_states').hide();
            $('.ca_states').val('');
            $('.other_states').hide();
            $('.other_states').val('');
        }
        else if($('#partner_master_address_attributes_country').val() == ('CA')){
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
    $($('#payment_type')).change(function() {
        if($('#payment_type').val() == ('PAYPAL')){
            document.getElementById("partner_payment_information_paypal_email").disabled=false;
            document.getElementById("partner_payment_information_ssn_for_us").disabled=false;
            document.getElementById("partner_payment_information_ssn_for_non_us").disabled=false;
        }
        else 
        {
            document.getElementById("partner_payment_information_paypal_email").disabled=true;
            document.getElementById("partner_payment_information_ssn_for_us").disabled=true;
        }   document.getElementById("partner_payment_information_ssn_for_non_us").disabled=true;
    });
    
    $("#frm_update_partner_master").validate({
        rules: {
            "partner_master[first_name]":{
                required: true
            },
            "partner_master[last_name]":{
                required: true
            },
            "partner_master[email]":{
                required: true,
                email: true
            },
            "partner_master[address_attributes][country]":{
                required: true
            },
            "partner_master[address_attributes][street]":{
                required: true
            },
            "partner_master[address_attributes][city]":{
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
            "partner_master[address_attributes][zip_code]":{
                required: true,
                minlength: 5,
                maxlength: 7,
                number: {
                    depends: function(element) {
                        if($("#partner_master_address_attributes_country").val() == 'US') {
                            return true;
                        }
                        else if($("#partner_master_address_attributes_country").val() == 'CA'){
                            return false;
                        }
                    }
                }
            },
            "partner_master[phone_number_attributes][area_code]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "partner_master[phone_number_attributes][phone1]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "partner_master[phone_number_attributes][phone2]":{
                required: true,
                number: true,
                minlength: 4,
                maxlength: 4
            }
        },
        messages: {
            "partner_master[first_name]":{
                required: "Please enter first name"
            },
            "partner_master[last_name]":{
                required: "Please enter last name"
            },
            "partner_master[email]":{
                required: "Please enter email",
                email: "Please enter a valid email address"
            },
            "partner_master[address_attributes][country]":{
                required: "Please select country"
            },
            "partner_master[address_attributes][street]":{
                required: "Please enter street"
            },
            "partner_master[address_attributes][city]":{
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
            "partner_master[address_attributes][zip_code]":{
                required: "Please enter zip code"
            },
            "partner_master[phone_number_attributes][area_code]":{
                required: "required"
            },
            "partner_master[phone_number_attributes][phone1]":{
                required: "required"
            },
            "partner_master[phone_number_attributes][phone2]":{
                required: "required"
            }
        }
    });

});

function frm_validate_partner_master(){
    
    if ($('#frm_update_partner_master').valid()){
      account_id = $("#partner_master_id").val()
      $.ajax({
      type: 'GET',
      url: "account/"+account_id+"/verify_paypal_account",
      data: { paypal_email: $( "#partner_payment_information_paypal_email" ).val()}
       })
      .done(function(result) {
        if (result == true){
          $('#frm_update_partner_master').submit()
        }else{
          $("<label class='error' for='other_state'>Email not varified with Paypal</label>").insertAfter("#partner_payment_information_paypal_email")
          $("#partner_payment_information_paypal_email").focus()
        }
    })
  }
}