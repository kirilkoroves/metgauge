var config = {
  apiKey: "AAAAyXZcdiQ:APA91bFciOpOTbc2ZimVEzzGI-yojI1OwzMjVZ6tqY3ZWJTx9Ehq3XffuNDxzjHHt-zdO3zFtnKzN4b-w_Fnrqp7GSBEj9USDXLKzpwOAMBo93_F_FRQdOenMPKQvRBBqjHTZzOtUxpX",
  authDomain: "timelyhero-5ae9c.firebaseapp.com",
  projectId: "timelyhero-5ae9c",
  storageBucket: "timelyhero-5ae9c.appspot.com",
  messagingSenderId: "865274197540",
  appId: "1:865274197540:web:e7cdd084d032ced6654ab1",
  measurementId: "G-R9YLZ9TK6F" 
};

try{
  firebase.initializeApp(config);
  var messaging = firebase.messaging();
  register(messaging);  
}
catch(e){}


function show_browser_notification(data){
  var click_action = data.click_action;
  var notificationTitle = data.title;
  var notificationOptions = {
      body: data.body,
      icon: data.icon,
      data: { url: click_action },
      click_action: click_action
  };
  var notification = new Notification(notificationTitle,notificationOptions);   
  notification.onclick = function () {
    window.location=click_action;
  }
}

window.show_browser_notification = show_browser_notification;

function subscribeTokenToTopic(token, topic) {
  fetch('https://iid.googleapis.com/iid/v1/'+token+'/rel/topics/'+topic, {
    method: 'POST',
    headers: new Headers({
      'Authorization': 'key='+config.apiKey
    })
  }).then(response => {
    if (response.status < 200 || response.status >= 400) {
      throw 'Error subscribing to topic: '+response.status + ' - ' + response.text();
    }
    console.log('Subscribed to "'+topic+'"');
    localStorage.setItem("firebase_token", token);
    localStorage.setItem("firebase_topic", topic);
  }).catch(error => {
    console.error(error);
  })
}

function unsubscribeTokenToTopic(token, topic) {
  fetch('https://iid.googleapis.com/iid/v1/'+token+'/rel/topics/'+topic, {
    method: 'DELETE',
    headers: new Headers({
      'Authorization': 'key='+config.apiKey
    })
  }).then(response => {
    if (response.status < 200 || response.status >= 400) {
      throw 'Error subscribing to topic: '+response.status + ' - ' + response.text();
    }
    console.log('Unsubscribed to "'+topic+'"');
  }).catch(error => {
    console.error(error);
  })
}


function register(messaging){
  if(messaging != null){
    navigator.serviceWorker.register('/assets/js/firebase-messaging-sw.js').then(registration => {
      firebase.messaging().useServiceWorker(registration)
      messaging.getToken().then(function(currentToken) {
        if (currentToken) {
          // Subscribe the devices corresponding to the registration tokens to the
          // topic.
          console.log("timely-messages" + window.user_id);
          subscribeTokenToTopic(currentToken, "timely-messages" + window.user_id);
        } else {
          // Show permission request.
          console.log('No Instance ID token available. Request permission to generate one.');
          // Show permission UI.
        }
      }).catch(function(err) {
        console.log('An error occurred while retrieving token. ', err);
        console.log('Error retrieving Instance ID token. ', err);
      });

      messaging.onTokenRefresh(function() {
        messaging.getToken().then(function(refreshedToken) {
          console.log('Token refreshed.');
          // Indicate that the new Instance ID token has not yet been sent to the
          // app server.
          // Send Instance ID token to app server.
          console.log("messages" + window.user_id);
          subscribeTokenToTopic(refreshedToken, "messages" + window.user_id);  
          // ...
        }).catch(function(err) {
          console.log('Unable to retrieve refreshed token ', err);
        });
      });

      messaging.onMessage(function(payload) {
        console.log("Asdasdasdasd");
        return show_browser_notification(event.data["firebase-messaging-msg-data"].notification);  
      });

      navigator.serviceWorker.addEventListener('message', function(event) {
        console.log(event);
        show_browser_notification(event.data["firebase-messaging-msg-data"].notification);
      });
    });
  }
}
window.register = register;