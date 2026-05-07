const {

  sendPushNotification,

  saveNotification,

} = require("./reservationHelpers");

const {

  notifyAssistantsAboutNewReservation,

} = require("./reservationAssistants");

// ============================================================
// 🆕 HANDLE NEW RESERVATION
// ============================================================

async function handleNewReservation({
  before,
  after,
  doctorId,
}) {

  try {

    // ========================================================
    // ✅ ONLY NEW RESERVATIONS
    // ========================================================

    if (before) return;

    const allowedStatuses = [
      "pending",
      "approved",
    ];

    if (
      !allowedStatuses.includes(after.status)
    ) {
      return;
    }

    console.log(
      "🔥 NEW RESERVATION TRIGGERED"
    );

    const token = after.patient_fcm;

    const patientUid = after.patient_uid;

    const isApproved =
      after.status === "approved";

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    const reservationDate =
      after.appointment_date_time || "غير محدد";

    const reservationType =
      after.reservation_type || "حجز";

    const orderNumber =
      after.order_num || "-";

    const title = isApproved
      ? "تم تأكيد حجزك ✅"
      : "تم استلام حجزك ⏳";

    const body = isApproved
      ? `📅 موعد الحجز: ${reservationDate}

🔢 رقم الحجز: ${orderNumber}

📋 نوع الحجز: ${reservationType}

⏳ تقدر تتابع دورك من التطبيق بسهولة

💊 بعد الكشف:
تقدر تبعت الروشتة ونوصلك العلاج لحد البيت 🚚`
      : `تم استلام حجزك بنجاح ✅

📅 موعد الحجز: ${reservationDate}

🔢 رقم الحجز: ${orderNumber}

📋 نوع الحجز: ${reservationType}

⏳ تابع دورك من التطبيق بسهولة

💡 بعد الكشف:
ممكن توصلك العلاج لحد البيت بدون تعب 🚚`;

    // ========================================================
    // 🧍 PATIENT PUSH
    // ========================================================

    if (token && patientUid) {

      await sendPushNotification({

        token,
        title,
        body,
      });

      await saveNotification({

        uid: patientUid,

        title,
        body,

        type: after.status,

        reservation: after,
      });

      console.log(
        "✅ Patient notification saved"
      );
    }

    // ========================================================
    // 👨‍⚕️ ASSISTANTS
    // ========================================================

    // 🔥 only notify assistants
    // when reservation is pending

    if (after.status === "pending") {

      await notifyAssistantsAboutNewReservation({

        doctorId,

        reservation: after,
      });
    }

  } catch (e) {

    console.error(
      "❌ NEW RESERVATION ERROR:",
      e
    );
  }
}

module.exports = {

  handleNewReservation,
};