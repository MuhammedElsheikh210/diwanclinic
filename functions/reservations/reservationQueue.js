const {

  sendPushNotification,

  saveNotification,

} = require("./reservationHelpers");

// ============================================================
// 🔔 HANDLE QUEUE UPDATE
// ============================================================

async function handleQueueUpdate({
  event,
  before,
  after,
}) {

  try {

    // ========================================================
    // ✅ ONLY WHEN QUEUE CHANGED
    // ========================================================

    if (!before) return;

    const queueChanged =

      before.queue_position !== after.queue_position ||

      before.queue_trigger !== after.queue_trigger;

    if (!queueChanged) return;

    const token = after.patient_fcm;

    const patientUid = after.patient_uid;

    if (!token || !patientUid) return;

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    const ahead = after.queue_position;

    // فقط لما يكون الدور قريب (0 أو 1 أو 2 قبلك)
    if (ahead > 2) return;

    const title = "تحديث الدور";

    const body =
      ahead === 0
        ? "دورك الآن ✨"
        : ahead === 1
        ? "قبلك من 1 إلى 2 حالات 🔔"
        : "قبلك من 2 إلى 3 حالات 🔔";

    // ========================================================
    // 🛑 PREVENT DUPLICATES
    // ========================================================

    const queueKey =
      `queue_notified_${ahead}`;

    if (after[queueKey]) return;

    // ========================================================
    // 🔔 PUSH
    // ========================================================

    await sendPushNotification({

      token,
      title,
      body,
    });

    // ========================================================
    // 💾 SAVE
    // ========================================================

    await saveNotification({

      uid: patientUid,

      title,
      body,

      type: "queue_update",

      reservation: after,
    });

    // ========================================================
    // ✅ MARK AS NOTIFIED
    // ========================================================

    await event.data.after.ref.update({

      [queueKey]: true,
    });

    console.log(
      "✅ Queue notification sent"
    );

  } catch (e) {

    console.error(
      "❌ QUEUE ERROR:",
      e
    );
  }
}

module.exports = {

  handleQueueUpdate,
};