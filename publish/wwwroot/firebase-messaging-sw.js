importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA0uE-uwqI40j0f_LgXHUBVnIC6XdIo6Lk",
  authDomain: "realestatecrm-b1b4f.firebaseapp.com",
  projectId: "realestatecrm-b1b4f",
  storageBucket: "realestatecrm-b1b4f.firebasestorage.app",
  messagingSenderId: "500882729962",
  appId: "1:500882729962:web:c2012a8f2202a9696ee093"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/img/icons/icon-48x48.png',
    badge: '/img/icons/icon-48x48.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});