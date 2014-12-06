//$(document).ready(function() {
//
//    console.log($("section.voicemail_name input#voicemail_name"));
//    $("section.voicemail_name input#voicemail_name").rules('add', {
//        required: true,
//        minlength: 3,
//        remote: {
//            url: "/settings/voicemails/check_for_uniq_name",
//            data: { "id": $("#voicemail_id").val()}
//        },
//        messages: {
//            required: "Please enter name", remote: "Name is taken."
//        }
//    });

//});