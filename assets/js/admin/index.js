$(function(){
      $(".ham-menu").click(function(e){
        e.preventDefault();
        if($("header").hasClass("opened")){
          $("header").removeClass("opened");
          $("#overlay").removeClass("show");
        }else{
          $("header").addClass("opened");
          $("#overlay").addClass("show");
        }
      });
    
      $(".close-link").click(function(e){
        e.preventDefault();
        $("header").removeClass("opened");
        $("#overlay").removeClass("show");
      });

      $("#overlay").click(function(e){
        e.preventDefault();
        $("header").removeClass("opened");
        $("#overlay").removeClass("show");
      });

      $(".tooltip-link").on("click", function(e){
          e.preventDefault();
      });

      $(".menu-notification.show").on("click", function(e){
        e.stopPropagation();
        if($(".notification-container").hasClass("hide")){
          $(".notification-container").removeClass("hide");
          $.ajax({
            url: "/get_notifications",
            success: function(response){
              $(".notification-result").html(response);
              limit = 10;
              offset = 10;
              reachedEnd = false;
              isActive = false;
              $(".notification-container .loading").hide();
            }
          });
        }else{
          $(".notification-container").addClass("hide");
        }
      });

      var limit = 10;
      var offset = 10;
      var reachedEnd = false;
      var isActive = false;


      $(".notification-container").scroll(function(){
          if (!isActive && $(".notification-container").scrollTop() >= $(".notification-result").height() - $(".notification-container").height()){
              isActive = true;
              getNotifications();
          }
      });

       function getNotifications(){
          if(reachedEnd){
              return;
          }
          $(".loading-more").show();
          $.ajax({
              url: "/get_notifications_lazy?limit="+limit+"&offset="+offset,
              method: "GET",
              success: function(response){
                  isActive = false;
                  if(response.reachedEnd){
                      reachedEnd = response.reachedEnd;
                  }else{
                      offset += limit;
                      $(".notification-result").append(response);
                  }
                  $(".loading-more").hide();
              }
          })
      }

      $(".notification-container").on("click", function(e){
        e.stopPropagation();
      });

      $(document).on("click", function(){
        $(".notification-container").addClass("hide");
        $(".menu-notification .over").removeClass("show");
      });

      $("[data-widget=AdminMenu]").on("click", function(){
        $(".notification-container").addClass("hide");
        $(".menu-notification .over").removeClass("show");
      });

      $(".close_notifications").on("click", function(e){
        e.preventDefault();
        $(".notification-container").addClass("hide");
        $(".menu-notification .over").removeClass("show");
      });


        $(".menu-item .dropdown-link").on("click", function(e){
              e.preventDefault();
              var menuItem = $(this).parent();
              $(".notification-container").addClass("hide");
              $(".menu-notification .over").removeClass("show");
              if(menuItem.hasClass("opened")){
                menuItem.removeClass("opened");
                menuItem.find(".overlay").removeClass("opened");
              }else{
                $(".menu-item").removeClass("opened");
                menuItem.addClass("opened");
                menuItem.find(".overlay").addClass("opened");
              }
          });
  
          $(".menu-item").on("click", function(e){
            e.stopPropagation();
          });
  
          $(".menu-item .overlay").on("click", function(e){
            $(".menu-item").removeClass("opened");
            $(".menu-item .overlay").removeClass("opened");
          });
  
           $(document).on("click", function(){
          $(".menu-item").removeClass("opened");
          $(".menu-item .overlay").removeClass("opened");
        });

        $(".menu-accordion .trigger").click(function(){
          if($(this).hasClass('selected')){
            $(this).removeClass('selected');
            $(this).children('.icon').removeClass('active');
            $(this).next().slideUp("fast", "linear");
            $(this).parent().removeClass('active');
          }else{
              $(".menu-accordion .trigger").removeClass('selected');
              $(this).addClass('selected');
              $(".menu-accordion .trigger").children('.icon').removeClass('active');
              $(this).children('.icon').addClass('active');
              $(".menu-accordion .trigger").next().slideUp("fast", "linear");
              $(this).next().slideDown("fast", "linear");
              $(".menu-accordion .item").removeClass('active');
              $(this).parent().addClass('active');
          }

      });


      $( ".notification-container" ).mouseenter(function() {
        $("html").css("scrollbar-width", "none");
        $( ".notification-container" ).css("scrollbar-width", "auto");
      });

      $( ".notification-container" ).mouseleave(function() {
        $("html").css("scrollbar-width", "auto");
        $( ".notification-container" ).css("scrollbar-width", "none");
      });

    $(".expand").click(function(e){
      e.preventDefault();
          var parentElem = $(this).parent().parent();
          console.log(parentElem);

        if(parentElem.hasClass('opened')){
          parentElem.removeClass('opened');
          parentElem.find('.panel').slideUp(300, "linear");
          parentElem.find('.chevron-icon').removeClass('active');
          parentElem.find('.action-txt').text("Expand");
        }else{
            parentElem.addClass('opened');
            parentElem.find('.panel').slideDown(300, "linear");
            parentElem.find('.chevron-icon').addClass('active');
            parentElem.find('.action-txt').text("Fold");
        }

    });
})


function toaster(type, message){
  if(type == "success"){
    $(".alert-info").html(message);
    $(".alert-info").show();
  }
}