import { db } from "./firebase.js";
import { collection, addDoc, serverTimestamp } 
from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

async function testFirebaseConnection() {
  try {
    const docRef = await addDoc(collection(db, "system_logs"), {
      message: "SUT Firebase connected successfully 🚀",
      status: "active",
      createdAt: serverTimestamp()
    });

    console.log("🔥 Firebase WORKING! Document ID:", docRef.id);
  } catch (error) {
    console.error("❌ Firebase Error:", error);
  }
}

testFirebaseConnection();
