$(document).ready(function () {
  $('#contact_tag_tokens').tokenInput('tags/index.json', {
    prePopulate: $('#contact_tag_tokens').data("pre"), 
    zindex:9999,
    theme:'facebook',
    propertyToSearch:'name',
    queryParam:'q',
    crossDomain: false
  });
});