const admin = require("firebase-admin");

admin.initializeApp();

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