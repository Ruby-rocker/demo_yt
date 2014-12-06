$(document).ready(function() {
    $($('#contact_address_attributes_country')).change(function() {
        if($('#contact_address_attributes_country').val() == ('US')){
            $('.us_states').show();
            $('.ca_states').hide();
            $('.ca_states').val('');
            $('.other_states').hide();
            $('.other_states').val('');
        }
        else if($('#contact_address_attributes_country').val() == ('CA')){
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
});