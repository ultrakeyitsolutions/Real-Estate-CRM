// firebase-messaging.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getMessaging, getToken } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging.js";

const firebaseConfig = {
  apiKey: "AIzaSyA0uE-uwqI40j0f_LgXHUBVnIC6XdIo6Lk",
  authDomain: "realestatecrm-b1b4f.firebaseapp.com",
  projectId: "realestatecrm-b1b4f",
  storageBucket: "realestatecrm-b1b4f.firebasestorage.app",
  messagingSenderId: "500882729962",
  appId: "1:500882729962:web:c2012a8f2202a9696ee093",
  measurementId: "G-YXQW7DG9M1"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

const vapidKey = 'BJtdDW_n_5JtS8EUIGVfoeAAp3R6iW-rXjq2SNjz2ndU6SJJ937pIYCZGoy6CQYmebEt30d8vSPBE-jodaCgZx0';
getToken(messaging, { vapidKey })
  .then((currentToken) => {
    if (currentToken) {
      console.log('Device token:', currentToken);
      alert('Device token: ' + currentToken);
    } else {
      console.log('No registration token available. Request permission to generate one.');
    }
  })
  .catch((err) => {
    console.log('An error occurred while retrieving token. ', err);
  });
