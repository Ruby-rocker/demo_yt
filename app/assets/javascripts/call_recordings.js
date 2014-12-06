function show_audio(div_id){
  $('#div_show_audio_'+div_id).toggleClass("active");
	var target = $('#div_show_audio_'+div_id).parent().children(".expand");
	$(target).slideToggle();
}
