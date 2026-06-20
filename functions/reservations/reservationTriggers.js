const { onValueWritten } = require(
  "firebase-functions/v2/database"
);

const {
  WHATSAPP_ACCESS_TOKEN,
  WHATSAPP_PHONE_NUMBER_ID,
} = require("../whatsapp/whatsappConfig");

const {

  handleNewReservation,

} = require("./reservationNotifications");

const {

  handleQueueUpdate,

} = require("./reservationQueue");

const {

  handleReservationStatusChange,

} = require("./reservationStatus");

// ============================================================
// 🔥 RESERVATION TRIGGER
// ============================================================

exports.onReservationUpdate = onValueWritten(
  {
    ref:
      "doctors/{doctorId}/reservations/{date}/{reservationId}",

    instance:
      "link-b47c8-default-rtdb",

    secrets: [WHATSAPP_ACCESS_TOKEN, WHATSAPP_PHONE_NUMBER_ID],
  },

  async (event) => {

    console.log(
      "🔥 RESERVATION FUNCTION TRIGGERED"
    );

    const before =
      event.data.before.val();

    const after =
      event.data.after.val();

    if (!after) return;

    const doctorId =
      event.params.doctorId;

    // ========================================================
    // 🆕 NEW RESERVATION
    // ========================================================

    await handleNewReservation({

      before,
      after,
      doctorId,
    });

    // ========================================================
    // 🔔 QUEUE UPDATE
    // ========================================================

    await handleQueueUpdate({

      event,
      before,
      after,
    });

    // ========================================================
    // 🔄 STATUS CHANGE
    // ========================================================

    await handleReservationStatusChange({

      event,

      before,
      after,

      doctorId,
    });
  }
);