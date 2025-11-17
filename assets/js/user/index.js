$(function(){
  if(getUrlVars()["success"] == "true"){
    toaster("success", "Successfully saved your changes");
  }
  $("#update-profile-btn").click(function(e){
      e.preventDefault();
      e.stopPropagation();
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
            window.location.href="/admin/users?success=true"
          }
          else{
            var fields = response.fields;
            $(".form-field").css({
              "border":"1px solid rgb(208, 213, 221)"
            });
            for(var i=0;i<fields.length;i++){
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").html(fields[i].message);
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").show();
              console.log( $(".invalid-feedback[for='profile_"+fields[i].field+"']").parent().find(".form-field"));
              $(".invalid-feedback[for='profile_"+fields[i].field+"']").prev().css({
                "border":"1px solid #F04438"
              });

            }
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
          }
        }
      })
    });

    $(document).on("click", ".delete-btn", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var id = $(this).attr("data-id");
      console.log(id);
      $(".confirm-delete-btn").attr("data-id", id);
      $("#deleteModal").modal("show"); 
    });

    $(document).on("click",".confirm-delete-btn", function(e){
      e.preventDefault();
      e.stopPropagation();
      var id = $(this).attr("data-id");
      $.ajax({
        url: "/admin/users/"+id+"/toggle_deactivate",
        method: "DELETE",
        headers: { "x-csrf-token": window.csrfToken },
        success: function(response){
          if(response.success){
            filter_users();
            $("#deleteModal").modal("hide"); 
          }
          else{
            alert(response.message);
            $("#deleteModal").modal("hide"); 
          }
        }
      });
    });

    $(document).on("click", ".activate-btn", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var id = $(this).attr("data-id");
      console.log(id);
      $(".confirm-activate-btn").attr("data-id", id);
      $("#activateModal").modal("show"); 
    });

    $(document).on("click", ".confirm-btn", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var id = $(this).attr("data-id");
      $.ajax({
        url: "/admin/users/"+id+"/confirm",
        method: "POST",
        headers: { "x-csrf-token": window.csrfToken },
        success: function(response){
          if(response.success){
            filter_users();
          }
          else{
            alert(response.message);
          }
        }
      });
    });

    
    $(document).on("click",".confirm-activate-btn", function(e){
      e.preventDefault();
      e.stopPropagation();
      var id = $(this).attr("data-id");
      $.ajax({
        url: "/admin/users/"+id+"/toggle_deactivate",
        method: "DELETE",
        headers: { "x-csrf-token": window.csrfToken },
        success: function(response){
          if(response.success){
            filter_users();
            $("#activateModal").modal("hide"); 
          }
          else{
            alert(response.message);
            $("#activateModal").modal("hide"); 
          }
        }
      });
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


    $(document).on("click", ".pagination-link.active", function(e){
      e.stopPropagation();
      e.preventDefault();
      var vars = getUrlVars();
      var query = "";
      console.log(vars);
      for(var i=0;i<vars.length;i++){
        if(vars[i] != "page"){
          query = query+"&"+vars[i]+"="+vars[vars[i]]
        }
      }
      window.location.href=window.location.origin+window.location.pathname+"?page="+$(this).attr("phx-value-page")+query
    });
});

function toaster(type, message){
  if(type == "success"){
    $(".alert-info").html(message);
    $(".alert-info").show();
  }
}

function filter_users(){
  var vars = getUrlVars();
  var query = "";
  console.log(vars);
  for(var i=0;i<vars.length;i++){
    if(vars[i] != "page"){
      query = query+"&"+vars[i]+"="+vars[vars[i]]
    }
  }
  var url="/admin/users/filter?page="+$(this).attr("phx-value-page")+query
  $.ajax({
    url: url,
    type: "GET",
    processData: false,
    success(response){
      $("#table_users").html(response);
    }
  })
}