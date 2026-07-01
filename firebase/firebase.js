import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";

import {
  getAuth,
  GoogleAuthProvider,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";

import {
  getFirestore,
  doc,
  setDoc,
  getDoc,
  collection,
  addDoc,
  getDocs,
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

export const auth = getAuth(app);
export const db = getFirestore(app);

const googleProvider = new GoogleAuthProvider();

window.currentUser = null;

// =========================
// REGISTER
// =========================
window.registerWithEmail = async (email, password) => {

  if (!email || !password) {
    alert("Jaza Email na Password.");
    return;
  }

  try {

    const credential = await createUserWithEmailAndPassword(
      auth,
      email,
      password
    );

    const user = credential.user;

    await setDoc(doc(db, "users", user.uid), {

      uid: user.uid,
      email: user.email,
      fullName: "",
      phone: "",
      role: "buyer",
      status: "active",
      verified: false,
      createdAt: serverTimestamp()

    });

    alert("Account imefunguliwa.");

  } catch (e) {

    alert(e.message);

  }

};

// =========================
// LOGIN
// =========================
window.loginWithEmail = async (email, password) => {

  try {

    await signInWithEmailAndPassword(
      auth,
      email,
      password
    );

    alert("Login Success");

  } catch (e) {

    alert(e.message);

  }

};

// =========================
// GOOGLE LOGIN
// =========================
window.loginWithGoogle = async () => {

  try {

    const result = await signInWithPopup(
      auth,
      googleProvider
    );

    const user = result.user;

    const ref = doc(db, "users", user.uid);

    const snap = await getDoc(ref);

    if (!snap.exists()) {

      await setDoc(ref, {

        uid: user.uid,
        email: user.email,
        fullName: user.displayName || "",
        phone: "",
        role: "buyer",
        status: "active",
        verified: true,
        createdAt: serverTimestamp()

      });

    }

    alert("Google Login Success");

  } catch (e) {

    alert(e.message);

  }

};

// =========================
// LOGOUT
// =========================
window.logoutUser = async () => {

  await signOut(auth);

};

// =========================
// SAVE PRODUCT
// =========================
export async function saveProduct(product) {

  await addDoc(collection(db, "products"), {

    ...product,
    createdAt: serverTimestamp()

  });

}

// =========================
// GET PRODUCTS
// =========================
export async function getProducts() {

  const snapshot = await getDocs(
    collection(db, "products")
  );

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

}

// =========================
// USER STATE
// =========================
onAuthStateChanged(auth, user => {

  window.currentUser = user;

  if (user) {

    console.log("Logged:", user.email);

  } else {

    console.log("No User");

  }

});
