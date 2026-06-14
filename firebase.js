import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";
import { 
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";

import { getFirestore } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyDTTV7h23M7RE4c4f3xa0GWWFVibs1HcOk",
  authDomain: "star-universal-trade-55d73.firebaseapp.com",
  projectId: "star-universal-trade-55d73",
  storageBucket: "star-universal-trade-55d73.appspot.com", // ✅ FIX HAPA (ilikuwa wrong)
  messagingSenderId: "528787064169",
  appId: "1:528787064169:web:f52d2b3cb0e8d36a1c29f8",
  measurementId: "G-ELLWGJZYFD"
};

const app = initializeApp(firebaseConfig);

// SERVICES
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// GOOGLE AUTH
export const googleProvider = new GoogleAuthProvider();

// HELPERS (STEP 3 & 4 READY)
export const loginWithGoogle = () => signInWithPopup(auth, googleProvider);
export const registerWithEmail = (email, password) =>
  createUserWithEmailAndPassword(auth, email, password);

export const loginWithEmail = (email, password) =>
  signInWithEmailAndPassword(auth, email, password);

export const logoutUser = () => signOut(auth);

export default app;
