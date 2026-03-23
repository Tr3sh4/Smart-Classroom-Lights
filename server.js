const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

// 🔥 LOAD FIREBASE KEY
const serviceAccount = require("./serviceAccountKey.json");

// 🔥 INITIALIZE FIREBASE
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

console.log("Firebase initialized successfully");

const app = express();
app.use(cors());
app.use(express.json());

// ✅ ROOT ROUTE
app.get("/", (req, res) => {
  res.json({
    message: "Firebase IoT API Running",
    endpoints: [
      "GET /lights",
      "POST /lights",
      "POST /lights/:id/toggle",
      "POST /lights/:id/dim",
      "PUT /lights/:id",
      "DELETE /lights/:id",
    ],
  });
});

// ✅ GET ALL LIGHTS
app.get("/lights", async (req, res) => {
  console.log("GET /lights called");
  try {
    const snapshot = await db.collection("lights").get();

    console.log(`Found ${snapshot.docs.length} documents in Firestore`);

    const lights = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    console.log(`Returning ${lights.length} lights`);
    res.json({ count: lights.length, lights });
  } catch (error) {
    console.error("Error fetching lights:", error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ ADD NEW LIGHT
app.post("/lights", async (req, res) => {
  try {
    const { name, dimLevel } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Name is required" });
    }

    const newLight = {
      name,
      state: "off",
      dimLevel: dimLevel || 30,
    };

    const docRef = await db.collection("lights").add(newLight);

    res.status(201).json({
      id: docRef.id,
      ...newLight,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ TOGGLE LIGHT
app.post("/lights/:id/toggle", async (req, res) => {
  try {
    const id = req.params.id;

    const docRef = db.collection("lights").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Light not found" });
    }

    const currentState = doc.data().state;

    const newState = currentState === "on" ? "off" : "on";

    await docRef.update({ state: newState });

    res.json({ message: "Toggled", state: newState });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ SET DIM
app.post("/lights/:id/dim", async (req, res) => {
  try {
    const id = req.params.id;
    const { dimLevel } = req.body;

    const docRef = db.collection("lights").doc(id);

    await docRef.update({
      state: "dim",
      dimLevel: dimLevel,
    });

    res.json({ message: "Dim updated" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ UPDATE LIGHT NAME
app.put("/lights/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const { name } = req.body;

    const docRef = db.collection("lights").doc(id);

    await docRef.update({ name });

    res.json({ message: "Updated" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ DELETE LIGHT
app.delete("/lights/:id", async (req, res) => {
  try {
    const id = req.params.id;

    await db.collection("lights").doc(id).delete();

    res.json({ message: "Deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ START SERVER (bind all addresses for emulator/device access)
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Firebase API running on http://${HOST}:${PORT} (localhost may be different from emulator host)`);
  if (HOST === "0.0.0.0") {
    console.log(`Try: http://127.0.0.1:${PORT}/lights or http://localhost:${PORT}/lights locally`);
    console.log(`Android emulator generally uses 10.0.2.2:${PORT}`);
  }

});