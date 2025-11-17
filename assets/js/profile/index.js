$(function(){

    $(".cover").css('height', ($(".cover").width()/100)*22.5);
    $( window ).resize(function() {
      $(".cover").css('height', ($(".cover").width()/100)*22.5);
    });


    function toJSON(str) {
      try {
        return JSON.parse(str);
      }catch(err) {
        return {};
      }
    };

  function createSlider($slider) {

    var baseConf = {
    'items': 3,
    'slideBy': 'page',
    'mouseDrag': true,
    'loop': false,
    'autoplayDirection': 'backward',
    'speed': '300',
    'autoplay': false,
    'navPosition': 'bottom', 
    'gutter': 8, 
    'nav': false,
    'controls': false,
    'preventScrollOnTouch': 'auto',
    'autoWidth': true,
    responsive: {
      324: {
        items: 4
      },
      768: {
        items: 4
      },
      1024: {
        items: 5
      },
      1280: {
        items: 7
      },
      1700:{
        items: 10
      }
     }
    }
    
    var slider_config = $slider.attr("data-js-config");
    var thisConfig = toJSON(slider_config.replace(/\'/g, '"'));
    var obj = $.extend({}, baseConf, thisConfig);

    if (window.tns) {                                        
      var tnsSlider = tns(obj);
    }         
  }

  var sliders = $('*[data-js="slider"]');
  for (var i=0; i < sliders.length; i++) {
    createSlider($(sliders[i]))
  }

  $("#update-profile-btn").click(function(){
      $(".admin-content").css("opacity", "0.5");
      $(".loading").css("display", "inline-block");
      var formData = new FormData($("form[name='profile']")[0]);
      $(".invalid-feedback").hide();
      $.ajax({
        url: $("form[name='profile']").attr("action"),
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        success(response){
          if(response.status == "OK"){
            var lang = "";
            if(formData.get("profile[language]") == "Japanese"){
              lang = "?lang=ja"
            }
            if(formData.get("profile[language]") == "Chinese"){
              lang = "?lang=zh_TW"
            }
            toastr.success('Successfully updated profile data', 'Success')
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
            $('html, body').scrollTop(0);
          }
          else{
            var fields = response.fields;
            for(var i=0;i<fields.length;i++){
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").html(fields[i].message);
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").show();
              console.log( $(".invalid-feedback[for='profile_"+fields[i].field+"']").parent().find(".form-field"));
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").parent().find(".form-field").css({
                "border":"1px solid #F04438"
              });
            }
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
          }
        }
      })
    });
      

      
    $("#profile_languages").select2({
      placeholder: window.profile_languages_placeholder,
      width: "100%"
    }).trigger("change");

    $("#profile_timezone").select2({
      width: "100%"
    });

    $('select').on('select2:opening select2:closing', function( event ) {
      var $searchfield = $( '#'+event.target.id ).parent().find('.select2-search__field');
      $searchfield.prop('disabled', true);
    });
    
    $("#upload-avatar").click(function(e){
      e.preventDefault();
      $("#profile_avatar_path").click();
    });

    $('#profile_avatar_path').change(function(){
      $(".remove_image_input").remove();
      const file = this.files[0];
      console.log(file);
      if (file){
        let reader = new FileReader();
        reader.onload = function(event){
          $('#profile-avatar').attr('src', event.target.result);
          $("#profile-avatar").css({
            "width":"100%",
            "height":"100%",
            "object-fit":"cover"
          }).removeClass("no_profile_img");
          $(".avatar-edit-btns").find("#remove-image").show();
        }
        reader.readAsDataURL(file);
      }
    });

    $("#upload-banner").click(function(e){
      e.preventDefault();
      $("#profile_cover_path").click();
    });

    $('#profile_cover_path').change(function(){
      $(".remove_cover_input").remove();
      const file = this.files[0];
      console.log(file);
      if (file){
        let reader = new FileReader();
        reader.onload = function(event){
          $('#profile-cover').attr('src', event.target.result);
          $(".cover-edit-btns").find("#remove-banner").show();
        }
        reader.readAsDataURL(file);
      }
    });

    $("#remove-image").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      $("form[name='profile']").append("<input type='hidden' name='profile[remove_image]' class='remove_image_input'/>");
      $("#profile-avatar").attr("src", "/assets/svg/generic/no_profile_photo.svg");
      $("#profile-avatar").css({
        "width":"auto",
        "height":"auto"
      }).addClass("no_profile_img");
      $(".avatar-edit-btns").find("#remove-image").hide();
    })

    $("#remove-banner").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      $("form[name='profile']").append("<input type='hidden' name='profile[remove_cover]' class='remove_cover_input'/>");
      $("#profile-cover").attr("src", "/assets/images/default_banner_image.png");
      $(".profile").find(".cover").attr("style", "background: url('/assets/images/default_banner_image.png')");;
      $(".cover-edit-btns").find("#remove-banner").hide();
    })

    $(".dropdown-menu").on("click", function(e){
      e.stopPropagation();
    });

    $(document).on("click", function(){
        $(".filter-item").find(".dropdown-menu").removeClass("opened");
    });

    $(".filter-item .dropdown-link").on("click", function(e){
        e.stopPropagation();
        e.preventDefault();
        var thisDropdown = $(this).parent().find(".dropdown-menu");
        $(".filter-item").find(".dropdown-menu").removeClass("opened");
        if(thisDropdown.hasClass("opened")){
            thisDropdown.removeClass("opened");
        }else{
            thisDropdown.addClass("opened");
        }
    });

    function createDateSlider($slider) {

      var baseConf = {
        'items': 2,
        'slideBy': 'page',
        'mouseDrag': true,
        'swipeAngle': false,
        'loop': true,
        'speed': '700',
         'autoplay': true,
         'autoplayDirection': 'forward',
          'gutter': 4,
          'nav': false,
         'controls': false,
         'preventScrollOnTouch': 'auto',
          "axis": "vertical",
          "autoplayButtonOutput": false
      }
  
      var slider_config = $slider.attr("data-js-config");
      var thisConfig = toJSON(slider_config.replace(/\'/g, '"'));
      var obj = $.extend({}, baseConf, thisConfig);
  
      if (window.tns) {
        var tnsSlider = tns(obj);
      }
    }

    var dateSliders = $('*[data-js="dates_slider"]');
    for (var i=0; i < dateSliders.length; i++) {
      createDateSlider($(dateSliders[i]))
    }
  if(getUrlVars()["event_type"] != null){
    setTimeout(function(){
      var scrollDiv = document.getElementById(decodeURI(getUrlVars()["event_type"])).offsetTop;
      window.scrollTo({ top: scrollDiv, behavior: 'smooth'});
    }, 500); 
  }
});
