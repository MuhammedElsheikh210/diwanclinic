const admin = require("firebase-admin");

const {
  getDoctorAssistants,
} = require("./reservationHelpers");

// ============================================================
// 🔔 NOTIFY ASSISTANTS ABOUT NEW RESERVATION
// ============================================================

async function notifyAssistantsAboutNewReservation({
  doctorId,
  reservation,
}) {

  try {

    console.log(
      "🔥 notifyAssistantsAboutNewReservation START"
    );

    console.log(
      "🧑‍⚕️ doctorId:",
      doctorId
    );

    console.log(
      "📄 reservation:",
      JSON.stringify(reservation, null, 2)
    );

    // ========================================================
    // 🔍 GET ASSISTANTS
    // ========================================================

    const assistants =
      await getDoctorAssistants(doctorId);

    console.log(
      "👨‍⚕️ assistants result:",
      JSON.stringify(assistants, null, 2)
    );

    // ========================================================
    // ❌ NO ASSISTANTS
    // ========================================================

    if (!assistants.length) {

      console.log(
        "❌ NO ASSISTANTS FOUND"
      );

      return;
    }

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    const patientName =
      reservation.patient_name || "مريض جديد";

    const reservationDate =
      reservation.appointment_date_time || "غير محدد";

    const reservationType =
      reservation.reservation_type || "حجز";

    const orderNumber =
      reservation.order_num || "-";

    const title = "🩺 حجز جديد";

    const body =
`👤 ${patientName}

📅 موعد الحجز: ${reservationDate}

🔢 رقم الحجز: ${orderNumber}

📋 نوع الحجز: ${reservationType}`;

    // ========================================================
    // 🔁 LOOP ASSISTANTS
    // ========================================================

    for (const assistant of assistants) {

      console.log(
        "👤 assistant object:",
        JSON.stringify(assistant, null, 2)
      );

      // ======================================================
      // ❌ INVALID UID
      // ======================================================

      if (!assistant.uid) {

        console.log(
          "❌ assistant has no uid"
        );

        continue;
      }

      console.log(
        "✅ assistant uid:",
        assistant.uid
      );

      // ======================================================
      // 📲 SEND PUSH NOTIFICATION
      // ======================================================

      try {

        if (assistant.fcm_token) {

          await admin.messaging().send({

            token: assistant.fcm_token,

            notification: {

              title,
              body,
            },
          });

          console.log(
            `📲 Push sent to assistant ${assistant.uid}`
          );

        } else {

          console.log(
            `❌ No fcm token for assistant ${assistant.uid}`
          );
        }

      } catch (pushError) {

        console.error(
          "❌ PUSH ERROR:",
          pushError
        );
      }

      // ======================================================
      // 🔔 CREATE NOTIFICATION
      // ======================================================

      const notifRef = admin
        .database()
        .ref(`notifications/${assistant.uid}`)
        .push();

      console.log(
        "📝 notif key:",
        notifRef.key
      );

      // ======================================================
      // 💾 SAVE NOTIFICATION
      // ======================================================

      await notifRef.set({

        key: notifRef.key,

        title,
        body,

        to_key: assistant.uid,

        user_type: "assistant",

        notification_type:
          "new_reservation",

        reservation_key:
          reservation.key,

        is_read: false,

        created_at: Date.now(),

        extra_data: reservation,
      });

      console.log(
        `✅ Assistant notified successfully: ${assistant.uid}`
      );
    }

    console.log(
      "🔥 notifyAssistantsAboutNewReservation END"
    );

  } catch (e) {

    console.error(
      "❌ ASSISTANTS NOTIFICATION ERROR:",
      e
    );
  }
}

// ============================================================
// 🔄 SYNC ASSISTANT NOTIFICATIONS
// ============================================================

async function syncAssistantNotifications({
  doctorId,
  reservation,
  status,
}) {

  try {

    console.log(
      "🔄 syncAssistantNotifications START"
    );

    console.log(
      "🧑‍⚕️ doctorId:",
      doctorId
    );

    console.log(
      "📄 reservation key:",
      reservation?.key
    );

    console.log(
      "📌 new status:",
      status
    );

    // ========================================================
    // 🔍 GET ASSISTANTS
    // ========================================================

    const assistants =
      await getDoctorAssistants(doctorId);

    console.log(
      "👨‍⚕️ assistants:",
      JSON.stringify(assistants, null, 2)
    );

    if (!assistants.length) {

      console.log(
        "❌ NO ASSISTANTS FOUND"
      );

      return;
    }

    // ========================================================
    // 🔁 LOOP ASSISTANTS
    // ========================================================

    for (const assistant of assistants) {

      console.log(
        "👤 assistant:",
        JSON.stringify(assistant, null, 2)
      );

      if (!assistant.uid) {

        console.log(
          "❌ assistant uid missing"
        );

        continue;
      }

      console.log(
        "🔍 searching notifications for:",
        assistant.uid
      );

      const notifSnap = await admin
        .database()
        .ref(`notifications/${assistant.uid}`)
        .orderByChild("reservation_key")
        .equalTo(reservation.key)
        .once("value");

      console.log(
        "📦 notifications exists:",
        notifSnap.exists()
      );

      notifSnap.forEach((child) => {

        console.log(
          "📝 updating notification:",
          child.key
        );

        child.ref.update({

          notification_type: status,

          extra_data: reservation,
        });
      });
    }

    console.log(
      "✅ syncAssistantNotifications END"
    );

  } catch (e) {

    console.error(
      "❌ ASSISTANT SYNC ERROR:",
      e
    );
  }
}

module.exports = {

  notifyAssistantsAboutNewReservation,

  syncAssistantNotifications,
};