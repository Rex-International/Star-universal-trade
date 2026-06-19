import { db } from "./firebase.js";
import { collection, addDoc, serverTimestamp } 
from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

async function testFirebase() {
  try {
    const docRef = await addDoc(collection(db, "system_logs"), {
      message: "SUT Firebase working ✔️",
      time: serverTimestamp()
    });

    alert("SUCCESS ✅ ID: " + docRef.id);
    console.log("Saved:", docRef.id);
  } catch (error) {
    alert("ERROR ❌ " + error.message);
    console.log(error);
  }
}

testFirebase();
