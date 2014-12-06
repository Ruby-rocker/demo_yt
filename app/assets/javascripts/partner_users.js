$(document).ready(function() {
    if($("#frm_partner_change_password"))
    {
        $("#frm_partner_change_password").validate({
            rules: {
                "partner_user[current_password]":{
                    required: true,
                    minlength: 8,
                    remote: {
                        url: "/partner_users/check_current_password"
                    }
                },
                "partner_user[password]":{
                    required: true,
                    minlength: 8
                },
                "partner_user[password_confirmation]":{
                    required: true,
                    minlength: 8,
                    equalTo: "#partner_user_password"
                }
            },
            messages: {
                "partner_user[current_password]":{
                    required: "Please enter current password",
                    minlength: "Min Length is 8 characters",
                    remote: "Current password is incorrect"
                },
                "partner_user[password]":{
                    required: "Please enter password"
                },
                "partner_user[password_confirmation]":{
                    required: "Please enter password confirmation"
                }
            }
        });
    }
});