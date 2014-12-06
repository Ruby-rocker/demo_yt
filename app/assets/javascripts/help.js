$(document).ready(function() {
    $("#form_save_help").validate({
        rules: {
            "help[question]":{
                required: true
            },
            "help[details]":{
                required: true
            },
            "help[first_name]":{
                required: true
            },
            "help[last_name]":{
                required: true
            },
            "help[area_code]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "help[phone1]":{
                required: true,
                number: true,
                minlength: 3,
                maxlength: 3
            },
            "help[phone2]":{
                required: true,
                number: true,
                minlength: 4,
                maxlength: 4
            },
            "help[email]":{
                required: true,
                email: true
            }
        },
        messages: {
            "help[question]":{
                required: "Please enter question"
            },
            "help[details]":{
                required: "Please enter details"
            },
            "help[first_name]":{
                required: "Please enter first name"
            },
            "help[last_name]":{
                required: "Please enter last name"
            },
            "help[area_code]":{
                required: "required"
            },
            "help[phone1]":{
                required: "required"
            },
            "help[phone2]":{
                required: "required"
            },
            "help[email]":{
                required: "Please enter email"
            }
        }
    });
});