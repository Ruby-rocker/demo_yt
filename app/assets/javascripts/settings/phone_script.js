$(document).ready(function() {

    $("#phone_script_form").validate({
        rules: {
            "phone_script[name]":{
                required: true,
                minlength: 3,
                remote: {
                    url: "/settings/phone_scripts/check_for_uniq_name",
                    data: { "id": $("#phone_script_id").val()}
                }
            },
            'voicemail[name]': {
                required: true,
                minlength: 3,
                remote: {
                    url: "/settings/voicemails/check_for_uniq_name",
                    data: { "id": $("#voicemail_id").val()}
                }
            },
            "phone_script[business_id]":'required',
            "voicemail[business_id]":'required',
            'voicemail[audio_file_attributes][record]': {
                required: function() { return $('#voicemail_audio_file_attributes_record').attr('value') == undefined; },
                extension: "wav|mp3"
            },
            "phone_script[calendar_id]":'required',
            "phone_script[script_id]":'required',
            'phone_script[not_available_excuse]':'required',
            "phone_script[desired_action]": {
                required: function() { return $('#phone_script_not_available_excuse').size() == 0; }
            },
            'phone_script[buss_name]':'required',
            'phone_script[question_1]':{
                required: function() { return $('#phone_script_calendar_id').size() == 0; }
            },
            "phone_script[buss_alerts]":'required',
            "phone_script[appointment_type]":'required',
            "phone_script[next_step]":'required',
            "phone_script[caller_objection]":'required'
        },
        messages: {
            "phone_script[name]":{
                required: "Please enter name",
//                minlength: "Min Length is 3 characters",
                remote: "Name is taken."
            },
            'voicemail[audio_file_attributes][record]': {required: 'Required', extension: 'Invalid file format'},
            "voicemail[name]":{
                required: "Please enter name",
                remote: "Name is taken."
            },
            "phone_script[business_id]":{
                required: "Please select business name"
            },
            "voicemail[business_id]":{
                required: "Please select business name"
            },
            "phone_script[script_id]":{
                required: "Please choose the desired outcome"
            }
        }
    }); // eof validate

    // SWAP OR NOT
    $('section.swap_number').on('change', 'input[name=phone_number_swap]', function () {
        $("div#tab-container :input").attr("disabled", this.id == 'phone_number_swap_false');
    });

    // TAB FOR LOCAL AND TOLL-FREE
    $('#tab-container').easytabs({
        animate: false
    }).bind('easytabs:after', function(evt, tab, panel, data) {
        if (tab.attr('id') == 'tab_tollfree'){
          $('section#displaying_results_local').hide();
          $('section#displaying_results_tollfree').show();
        }
        else if (tab.attr('id') == 'tab_local'){
          $('section#displaying_results_local').show();
          $('section#displaying_results_tollfree').hide();
        }
    });

    // TIME PAIR
    $('input.timeInput').timepicker({
        'showDuration': true,
        'maxTime': '11:30pm', 'rangeError': true
    }).bind('keypress', function(event){ // disable keyboard inputs except tab
        if (event.keyCode == 9){ return true; }
        else { event.preventDefault(); }
    });

    // DISABLE & ADD/REMOVE RULES FOR HOURS SELECTION
    function modifyTimeInput(el){
        if (el.value == 0 || el.value == 1){
            $('input.' + el.id.split('_')[6] + '_input').attr("disabled", true).removeClass('error').each(function() {
                $(this).rules('remove');
                $('label[for='+ this.id +']').hide();
            });
        } else {
            $('input.' + el.id.split('_')[6] + '_input').attr("disabled", false).each(function() {
                $(this).rules('add', {
                    required: true,
                    messages: { required:  "Required" }
                });
            });
        } // eof else
    }
    $('select.day_status').each(function() {
        modifyTimeInput(this);
    }).bind('change', function(){
        modifyTimeInput(this);
    });

    // DISABLE & ADD/REMOVE RULES FOR PHONE NUMBER INPUT
    function phoneNumberRules(el){
        var len = el.id.search('_phone2') == -1 ? 3 : 4;
        $(el).rules('add', {
//            required: true,
            min: function() { return el.value == '' ? false : 0 },
            integer: function() { return el.value != '' },
            number: function() { return el.value != '' },
            minlength: function() { return el.value == '' ? false : len },
            maxlength: function() { return el.value == '' ? false : len },
            messages: {
                required:  "Required", integer: 'Invalid',
                number: 'Invalid', min: 'Invalid', minlength: 'Invalid', maxlength: 'Invalid'
            }
        });
    }
    function modifyPhoneInput(flag, className){
        $(className).attr("disabled", flag);
        if (flag){
            $(className).removeClass('error').each(function() {
                $(this).rules('remove');
                $('label[for='+ this.id +']').hide();
            });
        } else {
            $(className).each(function() {
                phoneNumberRules(this);
            });
        } // eof else
    }

    // DURING HOURS
    $("input[name='phone_script[phone_script_hour_attributes][during_hours_call_center]']").each(function(){
        if ($(this).is(':checked')){
            modifyPhoneInput(this.id == 'phone_script_phone_script_hour_attributes_during_hours_call_center_true', 'input.during_input');
        }
    }).bind('change', function(){
        modifyPhoneInput(this.id == 'phone_script_phone_script_hour_attributes_during_hours_call_center_true', 'input.during_input');
    });

    // AFTER HOURS
    $("input[name='phone_script[phone_script_hour_attributes][after_hours_call_center]']").each(function(){
        if ($(this).is(':checked')){
            modifyPhoneInput(this.id == 'phone_script_phone_script_hour_attributes_after_hours_call_center_true', 'input.after_input');
        }
    }).bind('change', function(){
        modifyPhoneInput(this.id == 'phone_script_phone_script_hour_attributes_after_hours_call_center_true', 'input.after_input');
    });

    // DISABLE & ADD/REMOVE RULES FOR AUDIO FILE INPUT
    function modifyAudioInput(flag){
        if (flag){
            $('input#phone_script_audio_file_attributes_record').attr("disabled", flag).removeClass('error').rules('remove');
            $("label[for=phone_script_audio_file_attributes_record]").hide();
        } else {
            $('input#phone_script_audio_file_attributes_record').attr("disabled", flag).rules('add', {
                required: function() { return $('#phone_script_audio_file_attributes_record').attr('value') == undefined; },
                extension: "wav|mp3",
                messages: { required:  "Required", extension: 'Invalid file format' }
            });
        } // eof else
    }
    $("input[name='phone_script[has_audio]']").each(function(){
        if ($(this).is(':checked')){
            modifyAudioInput(this.id == 'phone_script_has_audio_false');
        }
    }).bind('change', function(){
           modifyAudioInput(this.id == 'phone_script_has_audio_false');
    });

    // EMAIL INPUT ADD/REMOVE VALIDATION RULES
    var counter_sms_email = 5;
    function EmailIdRules(el){
//        var flag = $('#voicemail_name').size() == 0 && el.value != '';
        $(el).rules('add', {
            required: function() { return $('#voicemail_name').size() != 0 },
            email: function() { return $('#voicemail_name').size() == 0 && el.value != '' },
            messages: {
                required:  "Required", email: 'Invalid'
            }
        });
    }
    $('input.email_input').each(function() {
        EmailIdRules(this);
    });
    $('ul#email_id_fields').on('click', 'a#remove_email_id', function(){
        $(this).closest('.'+ this.id).hide();
        if ($('li.remove_email_id:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=email_ids_fields_blueprint]').hide(); }
        else { $('a[data-blueprint-id=email_ids_fields_blueprint]').show(); }
    }).on('nested:fieldAdded:email_ids', function(event){
        var field = event.field;
        field.find('input').each(function(){
            EmailIdRules(this);
        });
        if ($('li.remove_email_id:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=email_ids_fields_blueprint]').hide(); }
        else { $('a[data-blueprint-id=email_ids_fields_blueprint]').show(); }
    });

    // SMS INPUT ADD/REMOVE VALIDATION RULES
    $('input.sms_input').each(function() {
        phoneNumberRules(this);
    });
    $('div#notify_numbers').on('click', 'a#remove_notify_number', function(){
        $(this).closest('.'+ this.id).hide();
        if ($('div.remove_notify_number:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=notify_numbers_fields_blueprint]').hide(); }
        else { $('a[data-blueprint-id=notify_numbers_fields_blueprint]').show(); }
    }).on('nested:fieldAdded:notify_numbers', function(event){
        var field = event.field;
        field.find('input').each(function(){
            phoneNumberRules(this);
        });
        if ($('div.remove_notify_number:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=notify_numbers_fields_blueprint]').hide(); }
        else { $('a[data-blueprint-id=notify_numbers_fields_blueprint]').show(); }
    });

//    FOR VOICEMAIL
    $('ul#notify_numbers').on('click', 'a#remove_notify_number', function(){
        $(this).closest('.'+ this.id).hide();
        if ($('li.remove_notify_number:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=notify_numbers_fields_blueprint]').hide(); }
        else { $('a[data-blueprint-id=notify_numbers_fields_blueprint]').show(); }
    }).on('nested:fieldAdded:notify_numbers', function(event){
            var field = event.field;
            field.find('input').each(function(){
                phoneNumberRules(this);
            });
            if ($('li.remove_notify_number:visible').length ==  counter_sms_email){ $('a[data-blueprint-id=notify_numbers_fields_blueprint]').hide(); }
            else { $('a[data-blueprint-id=notify_numbers_fields_blueprint]').show(); }
    });

    function SmsEmailInputs(){
        if ($('input[type=checkbox]#phone_script_call_receive').is(':checked') || $('input[type=checkbox]#phone_script_agent_action').is(':checked')){
            $('section#notification_input :input').attr("disabled", false);
            $('section#notification_input a').unbind('click');
        } else {
            $('section#notification_input :input').attr("disabled", true).removeClass('error');
            $('section#notification_input label.error').hide();
            $('section#notification_input a').click(function () {return false;});
        }
    }
    SmsEmailInputs();
    $('input[type=checkbox]#phone_script_call_receive').bind('change', function(){
        SmsEmailInputs();
    });
    $('input[type=checkbox]#phone_script_agent_action').bind('change', function(){
        SmsEmailInputs();
    });


    function NormalHours(){
        if($("input:radio.normal_hours:checked").val() == "true"){
            $(".eveningHours").hide();
            $(".bh").show();
            $(".mh").hide();
        }
    }
    NormalHours();
    $("input:radio.normal_hours").bind('change', function(){
        NormalHours();
    });

    function SplitHours(){
        if($("input:radio.split_hours:checked").val() == "false"){
            $(".eveningHours").show();
            $(".mh").show();
            $(".bh").hide();
        }
    }
    SplitHours();
    $("input:radio.split_hours").bind('change', function(){
        SplitHours();
    });

}); // eof document).ready(function
