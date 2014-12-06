function frm_rejoin_validation(){
	$("#rejoin_form").validate({
		rules: {
      "user[first_name]":{
        required: true
      },
      "user[last_name]":{
        required: true
      },
      "user[phone_number][area_code]": {
        required: true,
        digits: true
      },
      "user[phone_number][phone1]": {
        required: true,
        digits: true
      },
      "user[phone_number][phone2]": {
        required: true,
        digits: true
      },
      "user[billing_info_attributes][first_name]": {
        required: true
      },
      "user[billing_info_attributes][last_name]": {
        required: true
      },
      "user[billing_info_attributes][phone_number_attributes][area_code]": {
        required: true,
        digits: true
      },
      "user[billing_info_attributes][phone_number_attributes][phone1]": {
        required: true,
        digits: true
      },
      "user[billing_info_attributes][phone_number_attributes][phone2]": {
        required: true,
        digits: true
      },
      "user[billing_info_attributes][address_attributes][street]": {
        required: true
      },
      "user[billing_info_attributes][address_attributes][suite]": {
        required: true
      },
      "user[billing_info_attributes][address_attributes][city]": {
        required: true
      },
      "user[billing_info_attributes][address_attributes][country]": {
        required: true
      },
      "user[billing_info_attributes][address_attributes][state]": {
        required: true
      },
      "user[billing_info_attributes][address_attributes][zip_code]": {
        required: true,
        digits: true
      },
      "user[card_type]": {
        required: true
      },
      "user[card_number]": {
        required: true,
        digits: true
      },
      "user[ccv]": {
        required: true,
        digits: true
      },
      "user[expiry_month]": {
        required: true
      },
      "user[expiry_year]": {
        required: true
      },
      "user[card_name]": {
        required: true
      },
      "acceptance": {
        required: true
      }
    },
    messages: {
      "user[first_name]":{
        required: "Please enter first name",
      },
      "user[last_name]":{
        required: "Please enter last name",
      },
      "user[phone_number][area_code]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[phone_number][phone1]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[phone_number][phone2]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[billing_info_attributes][first_name]": {
        required: "Please enter first name"
      },
      "user[billing_info_attributes][last_name]": {
        required: "Please enter last name"
      },
      "user[billing_info_attributes][phone_number_attributes][area_code]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[billing_info_attributes][phone_number_attributes][phone1]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[billing_info_attributes][phone_number_attributes][phone2]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[billing_info_attributes][address_attributes][street]": {
        required: "Please enter street address"
      },
      "user[billing_info_attributes][address_attributes][suite]": {
        required: "Please enter suite"
      },
      "user[billing_info_attributes][address_attributes][city]": {
        required: "Please enter name of city"
      },
      "user[billing_info_attributes][address_attributes][country]": {
        required: "Please select name of country"
      },
      "user[billing_info_attributes][address_attributes][state]": {
        required: "Please select name of state"
      },
      "user[billing_info_attributes][address_attributes][zip_code]": {
        required: "Required",
        digits: "Only digits are allowed"
      },
      "user[card_type]": {
        required: "Please select card type"
      },
      "user[card_number]": {
        required: "Please enter card number",
        digits: "Only digits are allowed"
      },
      "user[ccv]": {
        required: "Please enter ccv number",
        digits: "Only digits are allowed"
      },
      "user[expiry_month]": {
        required: "Please select expiry month of card"
      },
      "user[expiry_year]": {
        required: "Please select expiry year of card"
      },
      "user[card_name]": {
        required: "Please enter card name"
      },
      "acceptance": {
        required: "Please accept terms and conditions"
      }
    }
	})
}

function check_coupon_code(){
  $.ajax({
    type: 'POST',
    url: '/registrations/check_coupen',
    data: { coupen_code: $( "#user_coupen_code" ).val(), total_price: $( "#selected_plan" ).val()}
  })
  .done(function(result) {
    if (result.success == true){
      if (result.discount.amount != null){
        $("#discount_type").val("amount")
        $("#discount_amount").val(result.discount.amount) 
        total_val = parseInt($("#subtotal").val().replace('$', ''))
        subtotal = "$" + (total_val - parseInt(result.discount.amount))
        $(".subtotal").html(subtotal)
      }else{
        $("#discount_type").val("percentage")
        $("#discount_amount").val(result.discount.percentage)
        total_val = parseInt($("#subtotal").val().replace('$', ''))
        subtotal = "$" + ((total_val * parseInt(result.discount.percentage)) / 100)
        $(".subtotal").html(subtotal)
      }
      $("#duration").val(result.discount.duration)
    }
  })
}