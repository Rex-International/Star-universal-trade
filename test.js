import { db } from "./firebase.js";
import { collection, addDoc } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

async function test() {
  try {
    await addDoc(collection(db, "test"), {
      message: "SUT connected successfully",
      time: Date.now()
    });
    console.log("Firebase WORKING 🔥");
  } catch (e) {
    console.error("Error:", e);
  }
}

test();
