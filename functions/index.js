const admin = require("firebase-admin");

admin.initializeApp();

// ============================================================
// 💬 PHARMACY CHAT
// ============================================================

const {

  onPharmacyChatMessage,

} = require(
  "./chat/chatTriggers"
);

exports.onPharmacyChatMessage =
  onPharmacyChatMessage;

// ============================================================
// 🧑‍⚕️ ASSISTANT CHAT
// ============================================================

const {

  onAssistantChatMessage,

} = require(
  "./chat/assistantChatTriggers"
);

exports.onAssistantChatMessage =
  onAssistantChatMessage;

// ============================================================
// 📣 DOCTOR ANNOUNCEMENTS
// ============================================================

const {

  onDoctorAnnouncementCreate,

} = require(
  "./announcements/announcementTriggers"
);

exports.onDoctorAnnouncementCreate =
  onDoctorAnnouncementCreate;

// ============================================================
// 🩺 RESERVATIONS
// ============================================================

const {

  onReservationUpdate,

} = require(
  "./reservations/reservationTriggers"
);

exports.onReservationUpdate =
  onReservationUpdate;

// ============================================================
// 💊 ORDERS — معطّل مؤقتاً
// ============================================================

// const {
//   onOrderUpdate,
// } = require("./orders/orderTriggers");
// exports.onOrderUpdate = onOrderUpdate;

// ============================================================
// 📲 WHATSAPP WEBHOOK (orders)
// ============================================================

const {
  whatsappWebhook,
} = require("./orders/whatsappWebhook");

exports.whatsappWebhook = whatsappWebhook;

// ============================================================
// 📤 SEND WHATSAPP — Callable from Flutter
// ============================================================

const { onCall } = require("firebase-functions/v2/https");
const { sendWhatsApp: _sendWhatsApp } = require("./whatsapp/whatsappSender");
const {
  WHATSAPP_ACCESS_TOKEN,
  WHATSAPP_PHONE_NUMBER_ID,
} = require("./whatsapp/whatsappConfig");

exports.sendWhatsAppMessage = onCall(
  {
    secrets: [WHATSAPP_ACCESS_TOKEN, WHATSAPP_PHONE_NUMBER_ID],
  },
  async (request) => {
    const { to, body } = request.data;

    if (!to || !body) {
      throw new Error("Missing required fields: to, body");
    }

    await _sendWhatsApp(to, body);
    return { success: true };
  }
);

// ============================================================
// 👤 USERS
// ============================================================

const {

  deleteAuthUser,

} = require(
  "./users/deleteAuthUser"
);

exports.deleteAuthUser =
  deleteAuthUser;