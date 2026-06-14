import {
  auth,
  googleProvider,
  signInWithPopup,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut
} from "./firebase.js";

import { GoogleAuthProvider } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";


// 🔐 EMAIL REGISTER
export async function registerWithEmail(email, password) {
  return await createUserWithEmailAndPassword(auth, email, password);
}

// 🔐 EMAIL LOGIN
export async function loginWithEmail(email, password) {
  return await signInWithEmailAndPassword(auth, email, password);
}

// 🔥 GOOGLE LOGIN
export async function loginWithGoogle() {
  const provider = new GoogleAuthProvider();
  return await signInWithPopup(auth, provider);
}

// 🚪 LOGOUT
export async function logoutUser() {
  return await signOut(auth);
}
