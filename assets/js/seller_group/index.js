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

  $("#save-btn").click(function(){
      $(".admin-content").css("opacity", "0.5");
      $(".loading").css("display", "inline-block");
      var formData = new FormData($("form[name='seller_group']")[0]);
      $(".invalid-feedback").hide();
      $.ajax({
        url: $("form[name='seller_group']").attr("action"),
        type: $("form[name='seller_group']").attr("method"),
        data: formData,
        contentType: false,
        processData: false,
        success(response){
          if(response.status == "OK"){
            var lang = "";
            window.location.href = "/admin/seller_groups";
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
          }
          else{
            var fields = response.fields;
            for(var i=0;i<fields.length;i++){
              $(".invalid-feedback[for='seller_group_"+fields[i].field+"']").html(fields[i].message);
              $(".invalid-feedback[for='seller_group_"+fields[i].field+"']").show();
              console.log( $(".invalid-feedback[for='seller_group_"+fields[i].field+"']").parent().find(".form-field"));
              $(".invalid-feedback[for='seller_group_"+fields[i].field+"']").parent().find(".form-field").css({
                "border":"1px solid #F04438"
              });
            }
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
          }
        }
      })
    });
      
    $("#profile_interests").select2({
      placeholder: window.profile_interests_placeholder,
      width: "100%"
    }).trigger("change");

    $('select').on('select2:opening select2:closing', function( event ) {
      var $searchfield = $( '#'+event.target.id ).parent().find('.select2-search__field');
      $searchfield.prop('disabled', true);
      $(".select2-dropdown--below").css("display", "block");
      $(".select2-dropdown--above").css("display", "block");
    });
    
    $("#upload-avatar").click(function(e){
      e.preventDefault();
      $("#seller_group_avatar_path").click();
    });

    $('#seller_group_avatar_path').change(function(){
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
      $("#seller_group_cover_path").click();
    });

    $('#seller_group_cover_path').change(function(){
      $(".remove_cover_input").remove();
      const file = this.files[0];
      console.log(file);
      if (file){
        let reader = new FileReader();
        reader.onload = function(event){
          console.log(event.target.result);
          $('#profile-cover').attr('src', event.target.result);
          $(".cover-edit-btns").find("#remove-banner").show();
        }
        reader.readAsDataURL(file);
      }
    });

    $("#remove-image").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      $("form[name='seller_group']").append("<input type='hidden' name='seller_group[remove_image]' class='remove_image_input'/>");
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
      $("form[name='profile']").append("<input type='hidden' name='seller_group[remove_cover]' class='remove_cover_input'/>");
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
});