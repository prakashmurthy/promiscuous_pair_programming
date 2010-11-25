(function($) {
  
  //$(function() {
  //  ppp.ui.showUserLocation();
  //})
  
  $(function() {
    $('#pairing_sessions_location_link').click(function() {
      $(this).hide();
      $('#pairing_sessions_location').show().find('input[type=text]').focus();
    })
  })
  
})(jQuery)