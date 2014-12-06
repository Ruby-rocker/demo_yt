$(document).ready(function() {
    $("#partner_logo_upload").validate({
        rules: {
            "partner_master[logo]":{
                required: true
            }
        },
        messages: {
            "partner_master[logo]":{
                required: "Please select logo"
            }
        }
    });
});