const admin = require("firebase-admin");
const { getDoctorAssistants } = require("../reservations/reservationHelpers");

// ============================================================
// 📲 SEND PUSH
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
// 💬 HANDLE NEW ASSISTANT CHAT MESSAGE
// ============================================================

async function handleNewAssistantChatMessage({ message, doctorKey, chatId }) {
  try {
    const senderId = message.senderId;
    if (!senderId) return;

    const msgText =
      message.isImage === true ? "📷 أرسل صورة" : message.text || "";
    const senderName = message.senderName || "رسالة جديدة";

    // ── is the sender the assistant (doctorKey namespace) ──
    const isAssistantSender = senderId === doctorKey;

    // ── read thread metadata to get tokens ──
    const threadSnap = await admin
      .database()
      .ref(`assistant_chats/${doctorKey}/chats/${chatId}`)
      .once("value");
    const thread = threadSnap.val();
    if (!thread) {
      console.log("❌ Thread not found:", chatId);
      return;
    }

    if (isAssistantSender) {
      // ── Assistant → notify patient ─────────────────────────
      const patientToken = thread.patientFcmToken;
      const patientId = thread.patientId;

      await sendPush(patientToken, senderName, msgText);

      console.log("✅ Patient notified:", patientId);
    } else {
      // ── Patient → notify all assistants of this doctor ─────
      const assistants = await getDoctorAssistants(doctorKey);

      if (assistants.length === 0) {
        // fallback: use stored token from thread
        const fallbackToken = thread.assistantFcmToken;
        console.log("⚠️ No assistants in DB, using thread token fallback");
        await sendPush(fallbackToken, senderName, msgText);
        return;
      }

      for (const assistant of assistants) {
        await sendPush(assistant.fcm_token, senderName, msgText);
      }

      console.log(`✅ ${assistants.length} assistant(s) notified`);
    }
  } catch (e) {
    console.error("❌ handleNewAssistantChatMessage error:", e);
  }
}

module.exports = { handleNewAssistantChatMessage };
