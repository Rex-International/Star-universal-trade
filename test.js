import { auth, db } from "./firebase.js";

import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithPopup,
  onAuthStateChanged,
  signOut
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";

import {
  collection,
  addDoc,
  serverTimestamp
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";


// ===============================
// FIREBASE CONNECTION TEST
// ===============================
async function testFirebaseConnection() {
  try {
    const docRef = await addDoc(collection(db, "system_logs"), {
      message: "SUT Firebase connected successfully",
      status: "active",
      createdAt: serverTimestamp()
    });

    console.log("🔥 Firebase WORKING! Document ID:", docRef.id);
  } catch (error) {
    console.error("❌ Firebase Error:", error.message);
  }
}

testFirebaseConnection();


// ===============================
// GOOGLE AUTH
// ===============================
const provider = new GoogleAuthProvider();

export async function loginWithGoogle() {
  try {
    const result = await signInWithPopup(auth, provider);
    const user = result.user;

    console.log("🔥 Google Login Success:", user.email);

    await addDoc(collection(db, "users"), {
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photo: user.photoURL,
      provider: "google",
      createdAt: serverTimestamp()
    });

    return user;

  } catch (error) {
    console.error("❌ Google login error:", error.message);
  }
}


// ===============================
// EMAIL SIGNUP
// ===============================
export async function registerWithEmail(email, password) {
  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    console.log("🔥 Signup success:", user.email);

    await addDoc(collection(db, "users"), {
      uid: user.uid,
      email: user.email,
      provider: "email",
      createdAt: serverTimestamp()
    });

    return user;

  } catch (error) {
    console.error("❌ Signup error:", error.message);
  }
}


// ===============================
// EMAIL LOGIN
// ===============================
export async function loginWithEmail(email, password) {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    console.log("🔥 Login success:", user.email);

    return user;

  } catch (error) {
    console.error("❌ Login error:", error.message);
  }
}


// ===============================
// LOGOUT
// ===============================
export async function logoutUser() {
  try {
    await signOut(auth);
    console.log("👋 User logged out");
  } catch (error) {
    console.error("❌ Logout error:", error.message);
  }
}


// ===============================
// AUTO SESSION TRACKING
// ===============================
onAuthStateChanged(auth, (user) => {
  if (user) {
    console.log("👤 Active user:", user.email || user.displayName);

    localStorage.setItem("sut_user", JSON.stringify({
      uid: user.uid,
      email: user.email,
      name: user.displayName || "",
      photo: user.photoURL || ""
    }));

  } else {
    console.log("🚫 No user logged in");
    localStorage.removeItem("sut_user");
  }
});
