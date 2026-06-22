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

const auth = getAuth(app);
const db = getFirestore(app);

const googleProvider = new GoogleAuthProvider();

window.currentUser = null;

// REGISTER
window.registerWithEmail = async (email, password) => {
  try {
    const user = await createUserWithEmailAndPassword(
      auth,
      email,
      password
    );

    alert("✅ Account Created");
    console.log(user);

  } catch (error) {
    alert(error.message);
  }
};

// LOGIN
window.loginWithEmail = async (email, password) => {
  try {
    const user = await signInWithEmailAndPassword(
      auth,
      email,
      password
    );

    alert("✅ Login Success");
    console.log(user);

  } catch (error) {
    alert(error.message);
  }
};

// GOOGLE LOGIN
window.loginWithGoogle = async () => {
  try {
    const result = await signInWithPopup(
      auth,
      googleProvider
    );

    alert("✅ Google Login Success");

  } catch (error) {
    alert(error.message);
  }
};

// LOGOUT
window.logoutUser = async () => {
  await signOut(auth);
  alert("👋 Logged Out");
};

// SAVE PRODUCT
export async function saveProduct(product) {

  await addDoc(collection(db, "products"), {
    ...product,
    createdAt: serverTimestamp()
  });

}

// USER STATE
onAuthStateChanged(auth, (user) => {

  if (user) {
    window.currentUser = user;

    console.log("Logged In:", user.email);

  } else {
    window.currentUser = null;

    console.log("No User");
  }

});
