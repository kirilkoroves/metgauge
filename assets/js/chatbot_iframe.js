$(document).ready(function(){
	setTimeout(function(){
		$(".floating-message").removeClass("hidden");
	}, 1500);

	setTimeout(function(){
		$(".floating-message").addClass("hidden");
	}, 6000);

	$(".floating-circle").mouseover(function(){
		$(".floating-message").removeClass("hidden");
	});

	$(".floating-circle").mouseleave(function(){
		$(".floating-message").addClass("hidden");
	});

	$(".floating-circle").click(function(e){
		$(".floating-message").addClass("hidden");
		$(".floating-circle").addClass("hidden");
		if($(".chatbot-iframe").attr("src") == "" || $(".chatbot-iframe").attr("src") == undefined){
			$(".chatbot-iframe").attr("src", window.chatbot_url+"&popup=true");
		}
		$(".chatbot-iframe").removeClass("hidden");
		$( ".chatbot-iframe" ).animate({
		    height: "395px"
		  }, 400 );

		setTimeout(function(){
			$(".chatbot-close").css("display", "block");
		}, 400);
	});
	$(".chatbot-close").click(function(){
		$( ".chatbot-iframe" ).animate({
		    height: "0px"
		}, 400 );
		$(".chatbot-close").css("display", "none");
		setTimeout(function(){
			$(".floating-circle").removeClass("hidden");
		}, 400);
	});	
})