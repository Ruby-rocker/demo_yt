// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// require jquery.tokeninput
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require ckeditor/init
//= require_tree
//= require autocomplete-rails
//= require jquery.tokeninput
//= require jquery.validate
//= require jquery_nested_form
//= require jquery.validate.additional-methods
//= require zeroclipboard
//= require tipsy

// For sending Ajax request with protect_from_forgery
function authToken() {
  return $('meta[name="csrf-token"]').attr('content');
}

function subscribe_call_recording(el){
//    console.log($(el).text());
  if ($(el).attr('disabled') == undefined && confirm('Are you sure want to Subscribe?') == true ) {
      $(el).attr('disabled',true);
      $(el).text('Wait...');
//      console.log('clicked-------');
      $("form").submit();
    return true;
  }else{
    return false;
  }
}

jQuery(document).ready(function(){
  var ww = document.body.clientWidth;

  $(document).ready(function() {
    $(".nav li a").each(function() {
      if ($(this).next().length > 0) {
        $(this).addClass("parent");
      };
    })

  $(".toggleMenu").click(function(e) {
    e.preventDefault();
    $(this).toggleClass("active");
    $(".nav").toggle();
  });
  adjustMenu();
  })

  $(window).bind('resize orientationchange', function() {
    ww = document.body.clientWidth;
    adjustMenu();
  });

  var adjustMenu = function() {
    if (ww < 768) {
      $(".toggleMenu").css("display", "inline-block");
      if (!$(".toggleMenu").hasClass("active")) {
          $(".nav").hide();
      } else {
          $(".nav").show();
      }
      $(".nav li").unbind('mouseenter mouseleave');
      $(".nav li a.parent").unbind('click').bind('click', function(e) {
          // must be attached to anchor element to prevent bubbling
          e.preventDefault();
          $(this).parent("li").toggleClass("hover");
      });
    }
    else if (ww >= 768) {
      $(".toggleMenu").css("display", "none");
      $(".nav").show();
      $(".nav li").removeClass("hover");
      $(".nav li a").unbind('click');
      $(".nav li").unbind('mouseenter mouseleave').bind('mouseenter mouseleave', function() {
          // must be attached to li so that mouseleave is not triggered when hover over submenu
          $(this).toggleClass('hover');
      });
    }
  }

  $("#plan1").mouseenter(function() {
    if ($("#selected_plan").val() != "1.50")
      $(this).attr('src', '/assets/pricing-button-hover.png')
  }).mouseleave(function() {
    if ($("#selected_plan").val() != "1.50")
      $(this).attr('src', '/assets/pricing-button-act1.png')
  });

  $("#plan2").mouseenter(function() {
    if ($("#selected_plan").val() != "250")
      $(this).attr('src', '/assets/pricing-button-hover.png')
  }).mouseleave(function() {
    if ($("#selected_plan").val() != "250")
      $(this).attr('src', '/assets/pricing-button-act1.png')
  });

  $("#plan3").mouseenter(function() {
    if ($("#selected_plan").val() != "500")
      $(this).attr('src', '/assets/pricing-button-hover.png')
  }).mouseleave(function() {
    if ($("#selected_plan").val() != "500")
      $(this).attr('src', '/assets/pricing-button-act1.png')
  });

  $("#plan1").click(function(){
    $('html, body').animate({scrollTop:$('#credit_info').position().top}, 'slow');
    $(".btn").attr('src', '/assets/pricing-button-act1.png')
    $(this).attr('src', '/assets/pricing-button-on.png')
    $("#selected_plan").val("1.50")
    $("#plan").val("pay_as_you_go")
    $(".second").hide()
    $("#subtotal").val(25)
    $(".subtotal, .total").html("$25")
  })

  $("#plan2").click(function(){
    $('html, body').animate({scrollTop:$('#credit_info').position().top}, 'slow');
    $(".btn").attr('src', '/assets/pricing-button-act1.png')
    $(this).attr('src', '/assets/pricing-button-on.png')
    $("#selected_plan").val("250")
    $("#plan").val("200minutes")
    $(".second").show()
    $(".second .money_span").html("$250")
    $(".second .minute_span").html("200")
    total = 25 + 250
    $("#subtotal").val(total)
    total_doller = "$" + total
    $(".subtotal, .total").html(total_doller)
  })

  $("#plan3").click(function(){
    $('html, body').animate({scrollTop:$('#credit_info').position().top}, 'slow');
    $(".btn").attr('src', '/assets/pricing-button-act1.png')
    $(this).attr('src', '/assets/pricing-button-on.png')
    $("#selected_plan").val("500")
    $("#plan").val("500minutes")
    $(".second").show()
    $(".second .money_span").html("$500")
    $(".second .minute_span").html("500")
    total = 25 + 500
    $("#subtotal").val(total)
    total_doller = "$" + total
    $(".subtotal, .total").html(total_doller)
  })

  $(".notification_world").hover(function(){
    $("#notification_panel").fadeToggle("fast");
    $.ajax({
      type: 'GET',
      url: '/notifications/create_user_notification_entry',
      success:function(data) {
        $('#notification_icon span').remove()
      }
    })
  }, function(){
    $("#notification_panel").fadeToggle("fast");
  });

  $('.fancybox').fancybox({
    helpers : {
      overlay: {
        css: {
          'background' : 'rgba(0,0,0, .5)'
          //'background': 'url("overlay_black.png") repeat scroll 0 0 transparent'
        } // css
      } // overlay
    } // helpers
  });

//  $('#clipboard_affiliate_link').tipsy();
  var clip_affiliate_link = new ZeroClipboard($("#clipboard_affiliate_link"));
  var clip_coupon_code = new ZeroClipboard($("#clipboard_coupon_code"));
  var clip_partner_link = new ZeroClipboard($("#clipboard_partner_link"));
  var clip_code_125 = new ZeroClipboard($("#clipboard_code_125"));
  var clip_code_160 = new ZeroClipboard($("#clipboard_code_160"));
  var clip_code_300 = new ZeroClipboard($("#clipboard_code_300"));
});

function chkTenant() {
  if ($("#tenant_subdomain")[0] && !$("#tenant_subdomain").val()){
    alert("Please select tenant")
    return false
  }
  return true
}



