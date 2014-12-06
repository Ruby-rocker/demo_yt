function remove_raw_contacts(close)
{
	$(close).closest("li").fadeOut(500, function() { $(this).remove(); })
}

function hard_remove_raw_contacts(id, close, type, hidden)
{
  if(confirm("Are you sure you want this delete this?"))
  {
    $.ajax({
      type: 'GET',
      dataType: 'script',
      url: '/contacts/'+type+'/'+ id,
      success: function () { $(close).closest("li").fadeOut(500, function() { $(this).remove(); $("#"+hidden).remove() }) }
    });
  }
}

function frm_validate_contact()
{
	$("#frm_save_contact").validate({
    rules: {
      "contact[first_name]":{
        required: true
      },
      "contact[last_name]":{
        required: true
      },
      "contact[address_attributes][zip_code]":{
        digits: {
            depends: function(element) {
                if($("#contact_address_attributes_country").val() == 'US') {
                    return true;
                }
                else if($("#contact_address_attributes_country").val() == 'CA'){
                    return false;
                }
            }
        }
      },
      "contact[phone_numbers_attributes][0][area_code]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][0][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][0][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      },
      "contact[phone_numbers_attributes][1][area_code]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][1][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][1][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      },
      "contact[phone_numbers_attributes][2][area_code]": {
        required: true,
        digits: true
      },
      "contact[phone_numbers_attributes][2][phone1]": {
        required: true,
        minlength: 3,
        digits: true
      },
      "contact[phone_numbers_attributes][2][phone2]": {
        required: true,
        minlength: 4,
        digits: true
      }
    },
    messages: {
      "contact[first_name]":{
        required: "Please enter first name"
      },
      "contact[last_name]":{
        required: "Please enter last name"
      },
      "contact[address_attributes][zip_code]":{
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][0][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][0][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][0][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][1][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][area_code]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][phone1]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      },
      "contact[phone_numbers_attributes][2][phone2]": {
        required: "Required",
        minlength: "Invalid Length",
        digits: "Only digits are allowed"
      }
    }
  });
  $("input[id*=contact_email_ids_attributes]").each(function() {
    $(this).rules("add", {
      email: true,
      messages: { email: "Must be in 'test@example.com' format" }
    });
  });
}

function add_phone_to_contact()
{
  $.ajax({
    type: 'GET',
    dataType: 'script',
    url: '/contacts/add_phone_to_contact',
    data: { 'count': ($('.cls_contact_phone_number .index_phone_count').last().val()) }
  });
}

function add_email_to_contact()
{
  $.ajax({
    type: 'GET',
    dataType: 'script',
    url: '/contacts/add_email_to_contact',
    data: { 'count': ($('.cls_contact_email_id .index_email_count').last().val()) }
  });
}

function load_ajax(url_path, html_id){
  $.ajax({
    type: 'GET',
    url: url_path,
    success: function (data) {
      $('#'+html_id).html(data);
    }
  }); // end of inner ajax
}

function warn_contact_del(count, id)
{
  flag = 0
  if(count > 0)
  {
    if(confirm("There are "+count+" Appointments available under this contact. Deleting contact will delete all these appointments"))
    {
      flag = 1
    }
  }
  else
  {
    flag = 1
  }
  if(flag == 1)
  {
    if(confirm("Are you sure you want to delete this contact ?"))
    {
      $.ajax({
        type: 'DELETE',
        dataType: 'script',
        url: '/contacts/'+id,
        data: {
          authenticity_token: authToken()
        }
      });
    }
  }
  return false;
}

function refreshpage()
{
  
$("#contact_form").submit()

}

$(document).ready(function () {

var $content = $(".content").show();
  $(".toggle_status").on("click", function(e){
    $(this).toggleClass("expanded");
    $content.slideToggle();
  });


var $content1 = $(".content_tag").show();
  $(".toggle_tag").on("click", function(e){
    $(this).toggleClass("expanded");
    $content1.slideToggle();
  });
  
});
function submit_status_through_link(link_element){
  $(link_element).parent().find("input").prop('checked', true)
  refreshpage()
}
function submit_tag_through_link(link_element){
  $(link_element).parent().find("input").prop('checked', true)
  refreshpage()
}