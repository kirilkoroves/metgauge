$(function(){
  if(getUrlVars()["success"] == "true"){
    toaster("success", "Successfully saved your changes");
  }
  $(".submit-btn").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      $(".admin-content").css("opacity", "0.5");
      $(".loading").css("display", "inline-block");
      var formData = new FormData($("form[name='client']")[0]);
      $(".invalid-feedback").hide();
      $.ajax({
        url: $("form[name='client']").attr("action"),
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        success(response){
          if(response.status == "OK"){
            window.location.href="/admin/clients?success=true"
          }
          else{
            var fields = response.fields;
            $(".form-field").css({
              "border":"1px solid rgb(208, 213, 221)"
            });
            for(var i=0;i<fields.length;i++){
              $(".invalid-feedback[for='client_"+fields[i].field+"']").html(fields[i].message);
              $(".invalid-feedback[for='client_"+fields[i].field+"']").show();
              console.log( $(".invalid-feedback[for='client_"+fields[i].field+"']").parent().find(".form-field"));
              $(".invalid-feedback[for='client_"+fields[i].field+"']").prev().css({
                "border":"1px solid #F04438"
              });

            }
            $(".admin-content").css("opacity", "1");
            $(".loading").css("display", "none");
          }
        }
      })
    });

    $(".delete-btn").click(function(e) {
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
        url: "/admin/clients/"+id,
        method: "DELETE",
        headers: { "x-csrf-token": window.csrfToken },
        success: function(response){
          if(response.success){
            $(".filter-submit").click();
            $("#deleteModal").modal("hide"); 
          }
          else{
            alert(response.message);
            $("#deleteModal").modal("hide"); 
          }
        }
      });
    });

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

    $(".pagination-link.active").click(function(e){
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

    $("#upload-logo").click(function(e){
      e.preventDefault();
      $("#client_logo_path").click();
    });

    $('#client_logo_path').change(function(){
      $(".remove_image_input").remove();
      const file = this.files[0];
      console.log(file);
      if (file){
        let reader = new FileReader();
        reader.onload = function(event){
          $('#client-logo-img').attr('src', event.target.result);
          $("#client-logo-img").css({
            "width":"100%",
            "height":"100%",
            "object-fit":"cover"
          }).removeClass("no_profile_img");
          $(".avatar-edit-btns").find("#remove-logo").show();
        }
        reader.readAsDataURL(file);
      }
    });

    $("#remove-logo").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      $("form[name='client']").append("<input type='hidden' name='client[remove_image]' class='remove_image_input'/>");
      $("#client-logo-img").attr("src", "/assets/images/placeholder-image.png");
      $("#client-logo-img").css({
        "width":"auto",
        "height":"auto"
      }).addClass("no_profile_img");
      $(".avatar-edit-btns").find("#remove-logo").hide();
    })
});

function toaster(type, message){
  if(type == "success"){
    $(".alert-info").html(message);
    $(".alert-info").show();
  }
}