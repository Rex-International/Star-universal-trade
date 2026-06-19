import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";

import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";

import {
  getFirestore,
  collection,
  addDoc,
  serverTimestamp
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyDTTV7h23M7RE4c4f3xa0GWWFVibs1HcOk",
  authDomain: "star-universal-trade-55d73.firebaseapp.com",
  projectId: "star-universal-trade-55d73",
  storageBucket: "star-universal-trade-55d73.appspot.com",
  messagingSenderId: "528787064169",
  appId: "1:528787064169:web:f52d2b3cb0e8d36a1c29f8"
};

const app = initializeApp(firebaseConfig);

// SERVICES
export const auth = getAuth(app);
export const db = getFirestore(app);

// GOOGLE AUTH
const googleProvider = new GoogleAuthProvider();

// 🔐 AUTH FUNCTIONS
export function loginWithGoogle() {
  return signInWithPopup(auth, googleProvider);
}

export function registerWithEmail(email, password) {
  return createUserWithEmailAndPassword(auth, email, password);
}

export function loginWithEmail(email, password) {
  return signInWithEmailAndPassword(auth, email, password);
}

export function logoutUser() {
  return signOut(auth);
}

// 📦 SAVE PRODUCT TO FIRESTORE
export async function saveProduct(product) {
  return await addDoc(collection(db, "products"), {
    ...product,
    createdAt: serverTimestamp()
  });
}

// 🌍 MAKE FUNCTIONS GLOBAL FOR HTML
window.loginWithGoogle = loginWithGoogle;
window.registerWithEmail = registerWithEmail;
window.loginWithEmail = loginWithEmail;
window.logoutUser = logoutUser;

// 👤 TRACK USER SESSION
onAuthStateChanged(auth, (user) => {
  if (user) {
    window.currentUser = user;
    console.log("🔥 Logged in:", user.email);
  } else {
    window.currentUser = null;
    console.log("❌ Logged out");
  }
});
