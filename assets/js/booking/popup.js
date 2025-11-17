$(document).ready(function(){
  event_desktor_or_mobile_setup();
});

window.onresize = event_desktor_or_mobile_setup;

function event_desktor_or_mobile_setup(){
  if(window.innerWidth < 768 ||
   navigator.userAgent.match(/Android/i) ||
   navigator.userAgent.match(/webOS/i) ||
   navigator.userAgent.match(/iPhone/i) ||
   navigator.userAgent.match(/iPod/i)) {
    $(".page-footer").addClass("hidden");          
    $(".mobile-view").css("display", "block");
    $(".flex.mobile-view").css("display", "flex");
  }
  else{
    $(".page-footer").removeClass("hidden");        
    $(".mobile-view").css("display", "none");
    $(".flex.desktop-view").css("display", "flex");
    $(".left.first-section").css("display", "block");
  }
  /**$(document).on("click", ".close-booking", function(){
    $("#bookingModal").hide();
  });

  $(document).on("click", ".back-booking", function(){
    $("#bookingModal").hide();
  });**/
  $(document).on("click", ".select-date", function(e){
    $(".left.first-section").css("display", "none");
  });

  $(document).on("click", ".select-date-cancel", function(e){
    $(".left.first-section").css("display", "block");
  });
}