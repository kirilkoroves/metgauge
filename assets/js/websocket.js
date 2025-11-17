var endpoint = window.endpoint;
var websocket = new WebSocket(endpoint);
var api_url = "/api";
var profile = null;

websocket.onopen = function(evt) { onOpen(websocket,  evt) };
websocket.onmessage = function(evt) { onMessage(websocket, evt); }
websocket.onerror = function(evt) { onError(evt); }
websocket.onclose = function(evt) { onClose(evt); } 
var topic = window.topic;

function onOpen(websocket, evt)
{
  console.log("CONNECTED");
  websocket.send(JSON.stringify({"event": "phx_join", "topic":"private_chat:"+window.user_email, "ref":"", "payload": {}}));
  if(window.only_private_chat == false){
    websocket.send(JSON.stringify({"event": "phx_join", "topic":"main", "ref":"", "payload": {"email": window.user_email, "host_email": window.host_email}}));
    websocket.send(JSON.stringify({"event": "phx_join", "topic":"chat:"+window.channel_id, "ref":"", "payload": {}}));
  }
  else{
    websocket.send(JSON.stringify({"event": "phx_join", "topic":"main", "ref":"", "payload": {"email": window.user_email, "host_email": window.user_email}}));
  }

  setInterval(function(){ 
    console.log("Send heartbeat");
    websocket.send(JSON.stringify({"event": "heartbeat", "topic":"phoenix", "ref":"", "payload":""})); 
  }, 20000);
}

function onClose(evt)
{
  console.log("DISCONNECTED");
}

function onMessage(websocket, evt)
{
  var data = JSON.parse(evt.data);
  //console.log(data);
  if(data["event"] === "phxError" && data["payload"]["response"] !== undefined && data["payload"]["response"]["reason"] !== undefined){
    alert(data["payload"]["response"]["reason"]);
  }

  if(data["event"] === "joinData" && data["payload"] !== undefined){
    profile = data["payload"]["profile"];
  }

  if(data["event"] === "newMessage" && data["payload"] !== undefined){
    var message = data["payload"];
    var email = data["userEmail"];
    var img_src = window.img_src;
    var class_response = "user-response";
    if(message["userId"] != null){
      img_src = window.seller_img_src;
      class_response = "chatbot-response";
    }
    if(message["automatic"] == false){
      $(".waiting-response").remove();
    }
    if(window.user_email != message["userEmail"]){
      if($(".enable_sound").hasClass("active")){
        speak_fn(message["content"]);
      }
    }
    $(".content").append('<div class="'+class_response+' user-section"><img src="'+img_src+'" class="chatbot-img"><div class="message">'+message["content"]+'</div></div>');
    $(".content").scrollTop(1000000);
    if(window.channel_email != window.user_email){
      websocket.send(JSON.stringify({"event": "mark_as_read", "topic":"private_chat:"+window.user_email, "ref":"", "payload": {"channel_id": window.channel_id}}));
    }
    if(message["automatic"]){
      setTimeout(function(){
        $(".content").append('<div class="chatbot-response user-section waiting-response"><img src="'+window.seller_img_src+'" class="chatbot-img"><div class="message"><img src="/assets/images/dots.gif" style="height: 36px;"></div></div>');
        $(".content").scrollTop(1000000);
      }, 1000);
    }
  }

  if(data["event"] === "newVideoCall" && data["payload"] !== undefined){
    var message = data["payload"];
    var img_src = window.img_src;
    var class_response = "user-response";
    var join_token = data["payload"]["joinTokenClient"];
    var join_button = "";
    if(message["userId"] != null){
      img_src = window.seller_img_src;
      class_response = "chatbot-response";
    }
    if(window.host_email == window.user_email){
      join_token = data["payload"]["joinTokenHost"];
      websocket.send(JSON.stringify({"event": "mark_as_read", "topic":"private_chat:"+window.user_email, "ref":"", "payload": {"channel_id": channel_id}}));
    }
    else{
      join_button = "<a href='"+window.videochat_url +"?token=" + join_token+"' class='btn primary'>"+window.join_text+"</a>";
    }
    if(message["automatic"] == false){
      $(".waiting-response").remove();
    }


    $(".content").append('<div class="'+class_response+' user-section"><img src="'+img_src+'" class="chatbot-img"><div class="video_call_message"><div class="video_call_icon"><img src="/assets/images/video-call.png"></div><div class="video_call_content">' + window.video_call_text+join_button+'</div></div></div>');
    $(".content").scrollTop(1000000);
    if(window.host_email == window.user_email){
      window.location.href = window.videochat_url +"?token=" + join_token;
    }
  }
  if(data["event"] == "readAll" && data["payload"] !== undefined){
    $("[data-id='"+data["payload"]["channelId"]+"'] .channel .header .count").html("");
    $("[data-id='"+data["payload"]["channelId"]+"'] .channel .header .count").removeClass("active");
  }

  if(data["event"] == "newChannelMessage" && data["payload"] !== undefined){
    var params = data["payload"];
    var chatbot_name = params["name"];
    var channel_user_email = params["userEmail"];
    var channel_user_name = params["userName"];
    var channel_id = params["channelId"];
    var chatbot_message_content = params["message"]["content"];
    var chatbot_message_type = params["message"]["type"];
    var chatbot_message_email = params["message"]["email"];
    var path = "/admin/timely_assist/channel/id/"+channel_id;
    var img_src = window.img_src;
    var class_response = "user-response";
    if(chatbot_message_email != channel_user_name){
      img_src = window.seller_img_src;
    }
    var message = chatbot_message_content;
    if(chatbot_message_type == "video_call"){
      message = window.video_call_text;
    }
    var unread_messages_count = 0;
    if($("[data-id='"+channel_id+"'] .channel .header .count span").length > 0){
      unread_messages_count_int = parseInt($("[data-id='"+channel_id+"'] .channel .header .count span").html());
      if(!isNaN(unread_messages_count_int)){
        unread_messages_count = unread_messages_count_int;
      }
      
    }
    unread_messages_count = unread_messages_count + 1;

    var channel_html = `
      <a href="${path}" data-id="${channel_id}">
        <div class="scheduled-event-item channel">
          <div class="header" style="align-items: flex-start;">
            <div class="content">
              <div class="message-content">
                  <div class="info">
                    <div class="chatbot-icon-div active" data-email="${channel_user_email}">
                      <svg class="chatbot-icon" width="24px" height="24px" viewBox="0 0 32 32" id="icon" xmlns="http://www.w3.org/2000/svg"><defs><style>.cls-1{fill:none;}</style></defs><title>chat-bot</title><path d="M16,19a6.9908,6.9908,0,0,1-5.833-3.1287l1.666-1.1074a5.0007,5.0007,0,0,0,8.334,0l1.666,1.1074A6.9908,6.9908,0,0,1,16,19Z"></path><path d="M20,8a2,2,0,1,0,2,2A1.9806,1.9806,0,0,0,20,8Z"></path><path d="M12,8a2,2,0,1,0,2,2A1.9806,1.9806,0,0,0,12,8Z"></path><path d="M17.7358,30,16,29l4-7h6a1.9966,1.9966,0,0,0,2-2V6a1.9966,1.9966,0,0,0-2-2H6A1.9966,1.9966,0,0,0,4,6V20a1.9966,1.9966,0,0,0,2,2h9v2H6a3.9993,3.9993,0,0,1-4-4V6A3.9988,3.9988,0,0,1,6,2H26a3.9988,3.9988,0,0,1,4,4V20a3.9993,3.9993,0,0,1-4,4H21.1646Z"></path><rect id="_Transparent_Rectangle_" data-name="<Transparent Rectangle>" class="cls-1" width="32" height="32"></rect></svg>
                      <h3>${chatbot_name}</h3>
                      <h5>${channel_user_name} (${channel_user_email})</h5>
                    </div>
                  </div>
                  <div> 
                      <div class="last_message">
                        <img src=${img_src} class="chatbot-img">
                        ${message}  
                      </div> 
                  </div>
              </div>
              <div class="count active">
                <span>
                 ${unread_messages_count}
                </span>
              </div>
            </div>
          </div>
        </div>
      </a>
    `;

    $("[data-id='"+channel_id+"'] ").remove()
    $(".channels").prepend(channel_html);
  }

  if(data["event"] === "presenceChange" && data["payload"] !== undefined){
    var joins = data["payload"]["joins"];
    var leaves = data["payload"]["leaves"];
    for(var i=0; i<joins.length;i++){
      $("[data-email='"+joins[i]+"']").addClass("active");
    }
    for(var i=0; i<leaves.length;i++){
      $("[data-email='"+leaves[i]+"']").removeClass("active");
    }
  }

  if(data["event"] == "presence_state" && data["payload"] !== undefined){
    console.log(data["payload"]);
    if(window.user_email == window.channel_email){
      $(".status_text").html(window.representative_offline);
      $(".status").removeClass("active");
      if(Object.keys(data["payload"]).indexOf(window.host_email) != -1){
        if(data["payload"][window.host_email].metas[0].status == "online"){
          $(".status_text").html(window.representative_online);
          $(".status").addClass("active");
        }
      }
    }
    else{
      $(".status_text").html(window.client_offline);
      $(".status").removeClass("active");
      if(Object.keys(data["payload"]).indexOf(window.channel_email) != -1){
        if(data["payload"][window.channel_email].metas[0].status == "online"){
          $(".status_text").html(window.client_online);
          $(".status").addClass("active");
        }
      }
    }
  }

  if(data["event"] == "presence_diff" && data["payload"] !== undefined){
    console.log(data["payload"]);
    var joins = Object.keys(data["payload"]["joins"]);
    var leaves = Object.keys(data["payload"]["leaves"]);
    if(window.user_email == window.channel_email){
      if(leaves.indexOf(window.host_email) != -1){
        $(".status_text").html(window.representative_offline);
        $(".status").removeClass("active");
      }
      if(joins.indexOf(window.host_email) != -1){
        $(".status_text").html(window.representative_online);
        $(".status").addClass("active");
      }
    }
    else{
      if(leaves.indexOf(window.channel_email) != -1){
        $(".status_text").html(window.client_offline);
        $(".status").removeClass("active");
      }
      if(joins.indexOf(window.channel_email) != -1){
        $(".status_text").html(window.client_online);
        $(".status").addClass("active");
      }
    }
  } 
}

function onError(evt)
{
  console.log("ERROR");
}

$(document).ready(function(){
  // var header_height = parseInt($(".chatbot-header").css("height").replace("px", ""));
  // if(header_height > 52 || $(document).width() < 768){
  //   var reduce = (header_height - 10);
  //   var max_height = parseInt($(".content").css("max-height").replace("px", "")) - reduce;
  //   $(".content").css("max-height", max_height+"px");
  // }
  // var reduce = -88 - (header_height - 30);
  // $(".send-message-tooltip").css("margin-top", reduce+"px")

  $(".send_message_btn").click(function(){
    var text = $(".send_message_input").val();
    $(".send_message_input").val(null);
    send_message(text);
  });

  $(".send_message_input").keydown(function(e){
    if (e.keyCode === 13 && e.ctrlKey) {
        //console.log("enterKeyDown+ctrl");
        $(this).val(function(i,val){
            return val + "\n";
        });
    }
    if (e.keyCode === 13 && e.shiftKey) {
        //console.log("enterKeyDown+ctrl");
        $(this).val(function(i,val){
            return val;
        });
    }
  });

  $(".send_message_input").keypress(function(e){
    if (e.keyCode === 13 && !e.ctrlKey && !e.shiftKey) {
      var text = $(".send_message_input").val();
      $(".send_message_input").val(null);
      send_message(text);   
      setTimeout(function(){
        $(".send_message_input").val(null);
      }, 100);
    }
  });
  
  $(".initial_question").click(function(e){
    send_message($(this).text().trim()); 
    $(this).remove();
  });

  $(".enable_sound").click(function(){
    if($(".enable_sound").hasClass("active")){
      $(".enable_sound").removeClass("active");
      $(".disabled_sound").css("display", "inline-block");
      $(".enabled_sound").css("display", "none");
    }
    else{
      $(".enable_sound").addClass("active");
      $(".disabled_sound").css("display", "none");
      $(".enabled_sound").css("display", "inline-block");
    }
  });

  $(".talk_to_representative").click(function(){
    websocket.send(JSON.stringify({"event": "talk_to_representative", "topic":"chat:"+window.channel_id, "ref":"", "payload": {}}));
    $.overlayhole.init();
    $.overlayhole.targets = $(".send_message_input").toArray();
    $(".talk_to_representative").css("visibility", "hidden");
    $.overlayhole.show();
    $(".send-message-tooltip").css("display", "flex");
    setTimeout(function(){
      $(".send-message-tooltip").css("display", "none");
      $.overlayhole.hide();
    }, 5500);
  });

  $(".video-call-button").click(function(){
    websocket.send(JSON.stringify({"event": "post_video_call", "topic":"chat:"+window.channel_id, "ref":"", "payload": {}}));
  });
});

function send_message(text){
  if(text != ""){
    text = text.replaceAll("\n", "<br/>");
    websocket.send(JSON.stringify({"event": "post_message", "topic":"chat:"+window.channel_id, "ref":"", "payload": {"type": "message", "content": text}}));
  }
}

function speak_fn(text){
  $.ajax({
    url: "/api/convert_text_to_speech",
    method: "POST",
    headers: {"x-csrf-token": window.csrfToken },
    data: {"text": text},
    success: function(response){
      var audioElement = document.createElement('audio');
      audioElement.setAttribute('src', response.path);
      audioElement.play();  
    },
    error: function(){
    }
  });
}

function updateChatContentHeight() {
  if($(".chatbot-header").length > 0){
    var header_height = parseInt($(".chatbot-header").css("height").replace("px", ""));
    var send_message_input_height = parseInt($(".send_message_input").css("height").replace("px", ""));
    console.log('Header Height: ' + header_height + ', Input Height: ' + send_message_input_height);
    var offsetHeight = header_height + send_message_input_height;

    var newHeight = $(window).height() - offsetHeight;
    $('.chatbot-class .chatbot .content').css({
        'max-height': newHeight + 'px',
        'height': newHeight + 'px'
    });
    $(".content").scrollTop(1000000);
  }
}

updateChatContentHeight();

$(window).resize(function() {
  updateChatContentHeight();
});