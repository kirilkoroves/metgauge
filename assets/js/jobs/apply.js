$(document).ready(function(){
  $(document).on("click", ".apply-job", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".invalid-feedback").hide();
    $(".apply-job").attr("disabled", "disabled");
    var btn=$(".apply-job");
    var formData = new FormData($("[name='apply']")[0]);
    $(".apply-form").css("opacity", "0.7");
    $(".loading").show();
    $.ajax({
        url: $("[name='apply']").attr("action"),
        type: $("[name='apply']").attr("method"),
        data: formData,
        contentType: false,
        enctype: 'multipart/form-data',
        processData: false,
        success: function(response) {
          $(".loading").hide();
          $(".apply-form").css("opacity", "1");
          if(response.status){
            $(".apply-form").hide();
            $(".apply-form-success").show();
            $(".proposal_count-"+response.id).html(parseInt($(".proposal_count-"+response.id).html())+1);
          }
          else{
            for(var i=0;i<response.errors.length; i++){
              $("[data-field='"+response.errors[i]["field"]+"']").html(response.errors[i]["message"]);
              $("[data-field='"+response.errors[i]["field"]+"']").show(); 
            }
            $(".all_errors").show();
            $(btn).removeAttr("disabled");
            
          }
        },
        error: function(error) {
          alert("Error submitting the form");
          $(btn).removeAttr("disabled");
          $(".loading").hide();
          $(".apply-form").css("opacity", "1");
        }
      });
  });
});

function setupForm(){
	$(".invalid-feedback").hide();
}
window.setupForm = setupForm;