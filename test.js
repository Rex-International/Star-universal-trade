import { db } from "./firebase.js";

import {
  collection,
  addDoc,
  serverTimestamp
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

async function testProductUpload() {
  try {
    const docRef = await addDoc(collection(db, "products"), {
      title: "SUT Test Product",
      price: 1000,
      vendor: "Gaby-International",
      vendorPhone: "0712345678",
      country: "Tanzania",
      createdAt: serverTimestamp()
    });

    console.log("✅ Product saved:", docRef.id);
    alert("✅ Product imehifadhiwa Firestore!");
  } catch (error) {
    console.error(error);
    alert("❌ Error: " + error.message);
  }
}

testProductUpload();
