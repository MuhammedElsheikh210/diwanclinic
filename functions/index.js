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
// 💊 ORDERS
// ============================================================

const {

  onOrderUpdate,

} = require(
  "./orders/orderTriggers"
);

exports.onOrderUpdate =
  onOrderUpdate;

// ============================================================
// 📲 WHATSAPP
// ============================================================

const {

  whatsappWebhook,

} = require(
  "./orders/whatsappWebhook"
);

exports.whatsappWebhook =
  whatsappWebhook;

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