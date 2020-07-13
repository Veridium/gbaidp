$(document).ready(function() {

    $('#byoi').submit();

    var checkit = function() {
      $('#authformid').submit();
    }

    var doNothing = function() {      
      setTimeout(checkit, 5000);
    }
  
    doNothing()
  
  })