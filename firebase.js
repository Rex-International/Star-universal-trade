import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyDTTV7h23M7RE4c4f3xa0GWWFVibs1HcOk",
  authDomain: "star-universal-trade-55d73.firebaseapp.com",
  projectId: "star-universal-trade-55d73",
  storageBucket: "star-universal-trade-55d73.appspot.com",
  messagingSenderId: "528787064169",
  appId: "1:528787064169:web:f52d2b3cb0e8d36a1c29f8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// 🔥 SERVICES
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

console.log("🔥 Firebase Initialized Successfully (SUT)");

export default app;
