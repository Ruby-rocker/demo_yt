function frm_validate_users_manage()
{
  $(".manageUsers .addUser #new_user").validate({
    rules: {
      "user[full_name]": {
        required: true
      },
      "user[email]": {
        required: true,
        email: true,
        remote: {
          url: "/settings/users/check_duplicate_email"
        }
      }
    },
    messages: {
      "user[full_name]":{
        required: "Please enter full name"
      },
      "user[email]":{
        required: "Please enter email",
        email: "Please enter a valid email address.",
        remote: "Email already present"
      }
    }
  });
}

function form_to_validate_users_fields(id){
  form_selector = $(id).closest('form')
  $(form_selector).validate({
    rules: {
      "user[full_name]": {
        required: true
      },
      "user[email]": {
        required: true,
        email: true
      }
    },
    messages: {
      "user[full_name]":{
        required: "Please enter full name"
      },
      "user[email]":{
        required: "Please enter email",
        email: "Please enter a valid email address."
      }
    }
  });
}

function submit_all_user(){
  $(".rowAction button").each(function(){
    this.click();
  })
}

function check_others(dropdown){
  if ($(dropdown).val() == "5")
    $(".reason_to_cancel").show()
  else
    $(".reason_to_cancel").hide()
}
