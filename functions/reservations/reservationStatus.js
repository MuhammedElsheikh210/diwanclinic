const {

  sendPushNotification,

  saveNotification,

} = require("./reservationHelpers");

const {

  syncAssistantNotifications,

} = require("./reservationAssistants");

// ============================================================
// 🔔 HANDLE RESERVATION STATUS CHANGE
// ============================================================

async function handleReservationStatusChange({
  event,
  before,
  after,
  doctorId,
}) {

  try {

    // ========================================================
    // ✅ ONLY EXISTING RESERVATIONS
    // ========================================================

    if (!before) return;

    const beforeStatus = before.status;

    const afterStatus = after.status;

    // ========================================================
    // 🛑 SAME STATUS
    // ========================================================

    if (beforeStatus === afterStatus) {
      return;
    }

    const patientUid = after.patient_uid;

    const token = after.patient_fcm;

    if (!patientUid) return;

    // ========================================================
    // 🛑 PREVENT DUPLICATES
    // ========================================================

    const notificationKey =
      `notified_${afterStatus}`;

    if (after[notificationKey]) {
      return;
    }

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    let title = "";

    let body = "";

    switch (afterStatus) {

      case "approved":

        title = "تم تأكيد الحجز ✅";

        body =
`حجزك رقم ${after.order_num} اتأكد 👍

⏳ تابع دورك من التطبيق

💊 بعد الكشف:
تقدر تبعت الروشتة ونوصلك العلاج لحد البيت 🚚`;

        break;

      case "completed":

        title = "ألف سلامة عليك 💙";

        body =
`تم الانتهاء من الكشف بنجاح ✅

💊 تقدر تطلب علاجك ويوصلك لحد البيت
🚚 بنفس سعر الصيدلية + توصيل مجاني

📱 افتح التطبيق واطلب دلوقتي`;

        break;

      case "cancelled_by_doctor":

      case "cancelled_by_assistant":

      case "cancelled_by_user":

        title = "تم إلغاء الحجز";

        body =
          after.cancelReason ||
          "تم الإلغاء";

        break;

      default:
        return;
    }

    // ========================================================
    // 🔔 PUSH
    // ========================================================

    if (token) {

      await sendPushNotification({

        token,
        title,
        body,
      });
    }

    // ========================================================
    // 💾 SAVE
    // ========================================================

    await saveNotification({

      uid: patientUid,

      title,
      body,

      type: afterStatus,

      reservation: after,
    });

    // ========================================================
    // 🔄 SYNC ASSISTANTS
    // ========================================================

    await syncAssistantNotifications({

      doctorId,

      reservation: after,

      status: afterStatus,
    });

    // ========================================================
    // ✅ MARK AS NOTIFIED
    // ========================================================

    await event.data.after.ref.update({

      [notificationKey]: true,
    });

    console.log(
      "✅ Status notification sent"
    );

  } catch (e) {

    console.error(
      "❌ STATUS ERROR:",
      e
    );
  }
}

module.exports = {

  handleReservationStatusChange,
};