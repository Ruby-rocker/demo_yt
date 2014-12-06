if(typeof(CKEDITOR) != 'undefined')
{
    CKEDITOR.config.toolbar = [
        [ 'Bold', 'Italic', 'Underline', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink' ]
    ];
    CKEDITOR.config.toolbar_LandingPage = [
        []
    ];
    (function($) {
jQuery.fn.cke_resize = function() {
   return this.each(function() {
      var $this = $(this);
      var rows = $this.attr('rows');
      var height = rows * 20;
      $this.next("div.cke").find(".cke_contents").css("height", height);
      //$this.next("div.cke").find(".cke_contents").css("border", none);
   });
};
})(jQuery);

CKEDITOR.on( 'instanceReady', function(){
  $("textarea.ckeditor").cke_resize();

})


} else{
    console.log("ckeditor not loaded")
}
