const admin = require("firebase-admin");
const axios = require("axios");
const { sendWhatsApp: _sendWhatsApp } = require("../whatsapp/whatsappSender");

// ============================================================
// 🔔 SEND PUSH NOTIFICATION
// ============================================================

async function sendPushNotification({
  token,
  title,
  body,
}) {

  if (!token) return;

  await admin.messaging().send({
    token,
    notification: {
      title,
      body,
    },
  });
}

// ============================================================
// 💾 SAVE NOTIFICATION
// ============================================================

async function saveNotification({
  uid,
  title,
  body,
  type,
  reservation,
}) {

  if (!uid) return;

  const notifRef = admin
    .database()
    .ref(`notifications/${uid}`)
    .push();

  await notifRef.set({
    key: notifRef.key,

    title,
    body,

    to_key: uid,

    user_type: "patient",

    notification_type: type,

    reservation_key: reservation?.key || null,

    is_read: false,

    created_at: Date.now(),

    extra_data: reservation || null,
  });
}

// ============================================================
// 👨‍⚕️ GET DOCTOR ASSISTANTS
// ============================================================

async function getDoctorAssistants(doctorId) {

  if (!doctorId) return [];

  const assistantsSnap = await admin
    .database()
    .ref("clients")
    .orderByChild("doctor_key")
    .equalTo(doctorId)
    .once("value");

  const assistants = assistantsSnap.val();

  if (!assistants) return [];

  return Object.values(assistants).filter(
    (assistant) =>
      assistant.userType === "assistant"
  );
}

// ============================================================
// 📞 FORMAT PHONE
// ============================================================

function formatPhone(phone) {

  const p = (phone || "").trim();

  if (p.startsWith("+"))  return p;
  if (p.startsWith("20")) return "+" + p;
  if (p.startsWith("0"))  return "+2" + p;

  return "+2" + p;
}

// ============================================================
// 📲 SEND WHATSAPP — Meta Cloud API
// ============================================================

async function sendWhatsApp(to, msg) {
  try {
    await _sendWhatsApp(to, msg);
  } catch (e) {
    console.error("❌ WhatsApp ERROR:", e.response?.data || e.message);
  }
}

module.exports = {

  sendPushNotification,

  saveNotification,

  getDoctorAssistants,

  formatPhone,

  sendWhatsApp,
};