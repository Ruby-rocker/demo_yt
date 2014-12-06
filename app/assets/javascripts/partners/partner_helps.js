$(document).ready(function() {
$("#form_save_partner_help").validate({
        rules: {
            "partner_help[question]":{
                required: true
            },
            "partner_help[details]":{
                required: true
            },
            "partner_help[first_name]":{
                required: true
            },
            "partner_help[last_name]":{
                required: true
            },
            "partner_help[area_code]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "partner_help[phone1]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "partner_help[phone2]":{
                required: true,
                number: true,
                minlength: 4,
                maxlength: 4
            },
            "partner_help[email]":{
                required: true,
                email: true
            }
        },
        messages: {
            "partner_help[question]":{
                required: "Please enter question"
            },
            "partner_help[details]":{
                required: "Please enter details"
            },
            "partner_help[first_name]":{
                required: "Please enter first name"
            },
            "help[last_name]":{
                required: "Please enter last name"
            },
            "partner_help[area_code]":{
                required: "required"
            },
            "partner_help[phone1]":{
                required: "required"
            },
            "partner_help[phone2]":{
                required: "required"
            },
            "partner_help[email]":{
                required: "Please enter email"
            }
        }
    });
});