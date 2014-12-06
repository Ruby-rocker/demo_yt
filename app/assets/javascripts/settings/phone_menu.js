$(document).ready(function() {

    $.validator.addMethod("uniq_digit", function (value, element) {
        return this.optional(element) || getDigitValues(element);
    });

    $.validator.addMethod("uniq_dep_name", function (value, element) {
        return this.optional(element) || getDepNameValues(element);
    });

    $("#phone_menu_form").validate({
        rules: {
            "phone_menu[name]":{
                required: true,
                minlength: 3,
                remote: {
                    url: "/settings/phone_menus/check_for_uniq_name",
                    data: { "id": $("#phone_menu_id").val()}
                }
            },
            "phone_menu[business_id]":'required',
            'phone_menu[audio_file_attributes][record]': {
                required: function() { return $('#phone_menu_audio_file_attributes_record').attr('value') == undefined; },
                extension: "wav|mp3"
            }
        },
        messages: {
            "phone_menu[name]":{
                required: "Please enter name",
                remote: "Name is taken."
            },
            "phone_menu[business_id]":{
                required: "Please select business name"
            },
            'phone_menu[audio_file_attributes][record]': {required: 'Required', extension: 'Invalid file format'}
        }
    });

    function depNumberRules(el){
        if (el.id.search('_other') == -1) {
            var len = el.id.search('_phone2') == -1 ? 3 : 4;
            var ind = el.id.split('_')[5];
            $(el).rules('add', {
                required: function() { return $('#phone_menu_digit_keys_attributes_'+ind+'_route_to').val() == ''; },
                min: 0,
                integer: true,
                number: true,
                minlength: len, maxlength: len,
                messages: {
                    required: "Required", integer: 'Invalid', number: 'Invalid',
                    min: 'Invalid', minlength: 'Invalid', maxlength: 'Invalid'
                }
            });
        } else {
            var len = el.id.search('_phone2') == -1 ? 3 : 4;
            $(el).rules('add', {
                required: true,
                min: 0,
                integer: true,
                number: true,
                minlength: len, maxlength: len,
                messages: {
                    required: "Required", integer: 'Invalid', number: 'Invalid',
                    min: 'Invalid', minlength: 'Invalid', maxlength: 'Invalid'
                }
            });
        }
    }

    function depNameRules(el){
        $(el).rules('add', {
            required: true,
            minlength: 3,
            uniq_dep_name: true,
            messages: {
                required:  "Required", uniq_dep_name: 'Duplicate'
            }
        });
    }

    function keyDigitRules(el){
        $(el).rules('add', {
            required: true,
            uniq_digit: true,
            messages: {
                required:  "Required", uniq_digit: 'Duplicate'
            }
        });
    }

    // CHECK FOR DUPLICATE DIGITS
    function getDigitValues(el){
        var values = $('select.KeyDigit:visible').map(function() {
            if (el.id != this.id) { return this.value; }
        }).toArray();
        return $.inArray(el.value, values) < 0;
    }

    // CHECK FOR DUPLICATE NAMES
    function getDepNameValues(el){
        var values = $('input.DepName:visible').map(function() {
            if (el.id != this.id) { return $.trim(this.value.toLowerCase().replace(/\s+/g, " ")); }
        }).toArray();
//        console.log(values);
        return $.inArray($.trim(el.value.toLowerCase().replace(/\s+/g, " ")), values) < 0;
    }

    // PHONE KEY INPUT ADD/REMOVE VALIDATION RULES
    var counter_phone_key = 9;
    $('select.KeyDigit').each(function() {
        keyDigitRules(this);
    });
    $('input.DepNumber').each(function() {
        depNumberRules(this);
    });
    $('input.DepName').each(function() {
        depNameRules(this);
    });
    $('div#phone_number_fields').on('click', 'a#remove_digit_key', function(){
        $(this).closest('.'+ this.id).hide();
        if ($('div.remove_digit_key:visible').length ==  counter_phone_key){ $('div#digit_keys_fields_add_link').hide(); }
        else { $('div#digit_keys_fields_add_link').show(); }
        $('select.KeyDigit:visible').each(function() {
            $(this).valid();
        });
        $('input.DepName:visible').each(function() {
            $(this).valid();
        });
    }).on('nested:fieldAdded:digit_keys', function(event){
        var field = event.field;
//            console.log(field.find('select.route_number'));
        field.find('input.DepNumber').each(function(){
            depNumberRules(this);
        });
        field.find('input.DepName').each(function(){
            depNameRules(this);
        });
        field.find('select.KeyDigit').each(function(){
            keyDigitRules(this);
        });
        if ($('div.remove_digit_key:visible').length ==  counter_phone_key){ $('div#digit_keys_fields_add_link').hide(); }
        else { $('div#digit_keys_fields_add_link').show(); }
    }).on('change', 'select.route_number', function(){
        var ind = this.id.split('_')[5];
        var area = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_area_code');
        var phone1 = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_phone1');
        var phone2 = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_phone2');
        if (this.value != ''){
            area.val('');
            phone1.val('');
            phone2.val('');
        }
        area.valid();
        phone1.valid();
        phone2.valid();
    }).on('blur', 'input.DepNumber', function(){
        var ind = this.id.split('_')[5];
        var area = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_area_code');
        var phone1 = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_phone1');
        var phone2 = $('#phone_menu_digit_keys_attributes_'+ind+'_phone_number_attributes_phone2');
        if (this.value.replace(/\s+/g, "").length > 0 && area.valid() && phone1.valid() && phone2.valid()) {
            $('#phone_menu_digit_keys_attributes_' + ind + '_route_to').val('');
        }
    });
});