const admin = require("firebase-admin");

admin.initializeApp();

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