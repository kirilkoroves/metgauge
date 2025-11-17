var jobOverlay = $(".jobs-overlay");
var jobDetails = $(".job-details");
function initFancySelect(){
      $('.fancy-select').each(function() {
          $(this).select2({
            dropdownParent: $(this).parent(),
            minimumResultsForSearch: Infinity,
            width: '100%'
          });

          $('.fancy-select').on('select2:open', function(e) {
              console.log("opened");
              const evt = "scroll.select2";
              $(e.target).parents().off(evt);
              $(window).off(evt);
            });

        });
  }
  
function ajaxCall(jobItemOverlay, url){
  $.ajax({
    url: url,
    type: 'GET',
    success: function(response) {
      if(jobItemOverlay){
        jobItemOverlay.removeClass("active");
      }
      jobDetails.html(response).addClass("active");
      jobOverlay.addClass("active");

      initFancySelect();

      jobOverlay.click(function(){
          $(this).removeClass("active");
          jobDetails.removeClass("active").empty();
        });
      window.setupForm();
      
    },
    error: function(error) {
      if(jobItemOverlay){
        jobItemOverlay.removeClass("active");
      }
    }
  });
}
window.ajaxCall = ajaxCall;

function openSuggestionsPage(id){
    var jobItemOverlay = $(".job-item-overlay");
    jobItemOverlay.addClass("active");
    ajaxCall(jobItemOverlay, '/jobs/seller/suggestions/' + id);
}
window.openSuggestionsPage = openSuggestionsPage;

function openProposalPage(actionBtn){
    var id = actionBtn.attr('id').split('-')[1];
    var jobItemOverlay = actionBtn.find(".job-item-overlay");
    jobItemOverlay.addClass("active");
    ajaxCall(jobItemOverlay, '/jobs/seller/proposals/' + id + '/show');
}
window.openProposalPage = openProposalPage;


$(function(){
  function openApplyForm(actionBtn){
      var id = actionBtn.attr('id').split('-')[1]; // Extract the id of job to use in edit function
      var jobItemOverlay = actionBtn.find(".job-item-overlay");
      jobItemOverlay.addClass("active");
      ajaxCall(jobItemOverlay, '/jobs/seller/job/' + id + '/apply');
  }
  window.openApplyForm = openApplyForm;




  function openCreateJobPage(actionBtn){
    var jobItemOverlay = actionBtn.find(".job-item-overlay");
    jobItemOverlay.addClass("active");
    ajaxCall(false, '/jobs/buyer/create');
  }

  function openEditJobPage(actionBtn){
    var jobItemOverlay = actionBtn.find(".job-item-overlay");
    var id = $(actionBtn).closest('.job-list-item').attr("data-id");
    jobItemOverlay.addClass("active");
    ajaxCall(false, '/jobs/buyer/'+id+'/edit');
  }

  function openCloneJobPage(actionBtn){
    var jobItemOverlay = actionBtn.find(".job-item-overlay");
    var id = $(actionBtn).closest('.job-list-item').attr("data-id");
    jobItemOverlay.addClass("active");
    ajaxCall(false, '/jobs/buyer/'+id+'/clone');
  }

  function openApplicantsPage(actionBtn){
    var id = actionBtn.attr('id').split('-')[1];
    var jobItemOverlay = actionBtn.find(".job-item-overlay");
    jobItemOverlay.addClass("active");
    ajaxCall(jobItemOverlay, '/jobs/buyer/' + id + '/applicants');
  }

  $('.job-list-grid.proposal .job-list-item .open_btn').click(function(e) {
      e.preventDefault();
      openProposalPage($(this).closest('.job-list-item'));
  });

  $('.job-list-grid.bookmark .job-list-item .apply_btn').click(function(e) {
      e.preventDefault();
      openApplyForm($(this).closest('.job-list-item'));
  });

  $('.create-job-btn').click(function(e) {
    e.preventDefault();
    openCreateJobPage($(this).closest('.job-list-item'));
  });

  $('.applicants-btn').click(function(e) {
    e.preventDefault();
    openApplicantsPage($(this).closest('.job-list-item'));
  });

  $('.suggestions_btn').click(function(e) {
    e.preventDefault();
    var id = $(this).attr("data-id");
    openSuggestionsPage(id);
  });

  $(document).on("click", ".job-item-menu-more", function(e){
    e.preventDefault();
    if($(this).parent().find(".job-item-menu").css("display") == "none"){
      $(".job-item-menu").css("display", "none");
      $(this).parent().find(".job-item-menu").css("display", "flex");
    }
    else{
      $(this).parent().find(".job-item-menu").css("display", "none");
    }
  });

  $(document).click(function(e){
    if(!$(e.target).hasClass("job-item-menu") && !$(e.target).hasClass("job-item-menu-more") && $(e.target).closest(".job-item-menu-more").length == 0){
      $(".job-item-menu").css("display", "none");
    }
  });

  $(document).click(function(e){
    if(!$(e.target).hasClass("job-item-menu") && !$(e.target).hasClass("job-item-menu-more") && $(e.target).closest(".job-item-menu-more").length == 0){
      $(".job-item-menu").css("display", "none");
    }
  });

  $(".edit-job").click(function(e) {
    e.preventDefault();
    openEditJobPage($(this).closest('.job-list-item'));
  });

  $('.clone-job').click(function(e) {
    e.preventDefault();
    openCloneJobPage($(this).closest('.job-list-item'));
  });

  $(".delete-job").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).closest('.job-list-item').attr("data-id");
    $(".confirm-delete-job").attr("data-id", id);
    $("#deleteModal").modal("show"); 
  });

  $(document).on("click",".confirm-delete-job", function(e){
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("data-id");
    $.ajax({
      url: "/jobs/buyer/"+id,
      method: "DELETE",
      headers: { "x-csrf-token": window.csrfToken },
      success: function(response){
        if(response.success){
          $("#job-"+id).remove();
          $("#deleteModal").modal("hide"); 
        }
        else{
          alert(response.message);
          $("#deleteModal").modal("hide"); 
        }
      }
    });
  });

  $(".item-tab-job").click(function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".item-tab-job").removeClass("active");
    $(this).addClass("active");
    $(".tab-job-content").hide();
    $("."+$(this).attr("data-link")).show();
  });

  $(document).on("click", ".cancel-proposal", function(e){
    e.preventDefault();
    jobOverlay.removeClass("active");
    jobDetails.removeClass("active").empty();
  });

  $(document).on("click",".delete_btn", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".confirm-delete").attr("data-id", $(this).attr("data-id"));
    $("#deleteModal").modal("show"); 
  });

  $(document).on("click",".incomplete_btn", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".confirm-incomplete").attr("data-id", $(this).attr("data-id"));
    $("#incompleteModal").modal("show"); 
  });

  $(document).on("click",".complete_btn", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".confirm-complete").attr("data-id", $(this).attr("data-id"));
    $("#completeModal").modal("show"); 
  });

  $(document).on("click",".confirm-delete", function(e){
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("data-id");
    $.ajax({
      url: "/jobs/seller/proposals/"+id,
      method: "DELETE",
      headers: { "x-csrf-token": window.csrfToken },
      success: function(response){
        if(response.success){
          $("#job-"+id).remove();
          $("#deleteModal").modal("hide"); 
        }
        else{
          alert("Error deleting proposal. Try again");
        }
      }
    });
  });

  $(document).on("click",".confirm-complete", function(e){
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("data-id");
    $(".confirm-complete").attr("disabled", "disabled");
    $(".confirm-complete").addClass("disabled");
    $.ajax({
      url: "/jobs/seller/proposals/confirm/"+id,
      method: "POST",
      headers: { "x-csrf-token": window.csrfToken },
      success: function(response){
        if(response.success){
          window.location.href="/jobs/seller/offers?proposal_id="+id;
        }
        else{
          alert(response.message);
          $(".confirm-complete").removeAttr("disabled");
          $(".confirm-complete").removeClass("disabled");
        }
      }
    });
  });

  $(document).on("click",".confirm-incomplete", function(e){
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("data-id");
    $(".confirm-incomplete").attr("disabled", "disabled");
    $(".confirm-incomplete").addClass("disabled");
    $.ajax({
      url: "/jobs/seller/proposals/cancel/"+id,
      method: "POST",
      headers: { "x-csrf-token": window.csrfToken },
      success: function(response){
        if(response.success){
          window.location.href="/jobs/seller/offers?proposal_id="+id;
        }
        else{
          alert(response.message);
          $(".confirm-incomplete").removeAttr("disabled");
          $(".confirm-incomplete").removeClass("disabled");
        }
      }
    });
  });

  $(document).on("click",".invite_btn", function(e){
    e.preventDefault();
    e.stopPropagation();
    var btn = $(this);
    var profile_id = $(this).attr("data-profile-id");
    var job_id = $(this).attr("data-job-id");
    $(btn).attr("disabled", "disabled");
    $(btn).addClass("disabled");
    $.ajax({
      url: "/jobs/seller/invite/",
      data: {"job_id": job_id, "profile_id": profile_id},
      method: "POST",
      headers: { "x-csrf-token": window.csrfToken },
      success: function(response){
        if(response.success){
          $(btn).html(window.sent_text);
          $(btn).removeClass("primary");
          $(btn).removeClass("invite_btn");
          $(btn).addClass("tertiary");
          $(btn).removeAttr("disabled");
          $(btn).removeClass("disabled");
        }
        else{
          alert(response.message);
          $(btn).removeAttr("disabled");
          $(btn).removeClass("disabled");
        }
      }
    });
  });

  $(document).on("click",".reject_btn", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".confirm-reject").attr("data-id", $(this).attr("data-id"));
    $("#rejectModal").modal("show"); 
  });

  $(document).on("click",".confirm-reject", function(e){
    e.preventDefault();
    e.stopPropagation();
    $(".confirm-reject").attr("disabled", "disabled");
    $(".confirm-reject").addClass("disabled");
    var id = $(this).attr("data-id");
    $.ajax({
      url: "/jobs/seller/reject_proposal/"+id,
      method: "POST",
      headers: { "x-csrf-token": window.csrfToken },
      data: {"rejected_reason": $("#rejected_reason").val()},
      success: function(response){
        if(response.status){
          $(".proposal-actions-"+id).html("<span class='danger-700'>"+window.reject_text+"</span>");
          $("#rejectModal").modal("hide"); 
          $(".confirm-reject").removeAttr("disabled");
          $(".confirm-reject").removeClass("disabled");
          $("#reject_reasons").val("");
        }
        else{
          alert("Error rejecting proposal. Try again");
        }
      }
    });
  });

});