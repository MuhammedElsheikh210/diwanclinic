const admin = require("firebase-admin");

// ============================================================
// 📲 HELPERS — reuse from orderHelpers pattern
// ============================================================

async function sendPush(token, title, body) {
  if (!token) return;
  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
      android: { priority: "high" },
      apns: { headers: { "apns-priority": "10" } },
    });
    console.log("✅ Push sent to:", token.slice(-10));
  } catch (e) {
    console.error("❌ Push error:", e.message);
  }
}

// ============================================================
// 🏥 FIND ALL PHARMACY STAFF (same pattern as orderPharmacy.js)
// ============================================================

async function findPharmacyStaff(pharmacyId) {
  const snap = await admin
    .database()
    .ref("clients")
    .orderByChild("pharmacy_id")
    .equalTo(pharmacyId)
    .once("value");

  const staff = [];
  snap.forEach((child) => {
    const val = child.val();
    if (val && val.userType === "pharmacy") staff.push(val);
  });
  return staff;
}

// ============================================================
// 💬 HANDLE NEW CHAT MESSAGE
// ============================================================

async function handleNewChatMessage({ message, pharmacyId, chatId }) {
  try {
    const senderId = message.senderId;
    if (!senderId) return;

    const msgText =
      message.isImage === true ? "📷 أرسل صورة" : message.text || "";
    const senderName = message.senderName || "رسالة جديدة";

    const isPharmacySender = senderId === pharmacyId;

    // Read thread metadata to get FCM tokens
    const threadSnap = await admin
      .database()
      .ref(`pharmacy_chats/${pharmacyId}/chats/${chatId}`)
      .once("value");
    const thread = threadSnap.val();
    if (!thread) return;

    if (isPharmacySender) {
      // ── Pharmacy → notify patient ──────────────────────────
      const patientId = thread.patientId;
      const patientToken = thread.patientFcmToken;

      await sendPush(patientToken, senderName, msgText);

      console.log("✅ Patient notified:", patientId);
    } else {
      // ── Patient → notify all pharmacy staff ───────────────
      const staffList = await findPharmacyStaff(pharmacyId);

      if (staffList.length === 0) {
        // fallback: use stored pharmacyFcmToken if no staff found
        const pharmacyToken = thread.pharmacyFcmToken;
        await sendPush(pharmacyToken, senderName, msgText);
        return;
      }

      for (const staff of staffList) {
        await sendPush(staff.fcm_token, senderName, msgText);
      }

      console.log(`✅ ${staffList.length} pharmacy staff notified`);
    }
  } catch (e) {
    console.error("❌ handleNewChatMessage error:", e);
  }
}

module.exports = { handleNewChatMessage };
