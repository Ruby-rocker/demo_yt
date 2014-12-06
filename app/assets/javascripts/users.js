$(document).ready(function() {
  if($("#frm_change_password"))
  {
    $("#frm_change_password").validate({
      rules: {
        "user[current_password]":{
          required: true,
          minlength: 8,
          remote: {
            url: "/users/check_current_password"
          }
        },
        "user[password]":{
          required: true,
          minlength: 8
        },
        "user[password_confirmation]":{
          required: true,
          minlength: 8,
          equalTo: "#user_password"
        }
      },
      messages: {
        "user[current_password]":{
          required: "Please enter current password",
          minlength: "Min Length is 8 characters",
          remote: "Current password is incorrect"
        },
        "user[password]":{
          required: "Please enter password"
        },
        "user[password_confirmation]":{
          required: "Please enter password confirmation"
        }
      }
    });
  }
    if($("#frm_update_user_info"))
    {
        $("#frm_update_user_info").validate({
            rules: {
                "user[first_name]":{
                    required: true
                },
                "user[last_name]":{
                    required: true
                }
            },
            messages: {
                "user[first_name]":{
                    required: "Please enter first name"
                },
                "user[last_name]":{
                    required: "Please enter last name"
                }
            }
        });
    }
});