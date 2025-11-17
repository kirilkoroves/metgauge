$(document).on("click", ".submit-job", function(e){
	e.preventDefault();
	e.stopPropagation();
	$(this).attr("disabled", "disabled");
	var categories = $.map($(".job-category-li.active"), function(elem){ 
		return "job[categories][]=" + encodeURIComponent($(elem).attr("data-id"));
	});
	$.ajax({
      url: $("#form-job").attr("action"),
      type: $("#form-job").attr("method"),
      data: $("#form-job").serialize() + "&" + categories.join("&"),
      success: function(response) {
        if(response.success){
        	window.location.reload();
        }
        else{
        	$(this).removeAttr("disabled");
        	$(".job-details").html(response.html);
        	setupForm();
        }
        
      },
      error: function(error) {
        if(jobItemOverlay){
          $(this).removeAttr("disabled");
          jobItemOverlay.removeClass("active");
        }
      }
    });
});

function setupForm(){
	if($("[name='job[job_type]']").val() == "part_time"){
		$(".type-footnote").html(window.part_time_text);
	}
	if($("[name='job[job_type]']").val() == "full_time"){
		$(".type-footnote").html(window.full_time_text);
	}

	$("[name='job[job_type]']").change(function(){
	  if($("[name='job[job_type]']").val() == "part_time"){
	  	$(".type-footnote").html(window.part_time_text);
	  }
	  if($("[name='job[job_type]']").val() == "full_time"){
	  	$(".type-footnote").html(window.full_time_text);
	  }
	});


	$(".job-category-li").click(function(){
		if($(this).hasClass("active")){
			$(this).removeClass("active");
		}
		else{
			$(this).addClass("active");	
		}
	});
}

window.setupForm = setupForm;