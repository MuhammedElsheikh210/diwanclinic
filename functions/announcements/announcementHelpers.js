const admin = require("firebase-admin");

// ============================================================
// 🏷️ ARABIC LABELS
// ============================================================

const typeLabels = {
  arrived: "✅ وصل الدكتور",
  delayed: "⏳ الدكتور متأخر",
  cancelled_today: "❌ الدكتور معتذر اليوم",
  temporary_break: "⏸️ الدكتور خرج مؤقتاً",
  resumed: "▶️ الدكتور رجع واستأنف",
};

// ============================================================
// 📋 BUILD NOTIFICATION BODY
// ============================================================

function buildAnnouncementMessage(announcement) {

  const type = announcement.type;

  const title = typeLabels[type] || "إعلان من الدكتور";

  let body = typeLabels[type] || "";

  if (announcement.reason) {
    body += ` — ${announcement.reason}`;
  }

  if (announcement.estimated_time) {
    body += `\n⏰ الوصول المتوقع: ${announcement.estimated_time}`;
  }

  return { title, body };
}

// ============================================================
// 📲 SEND PUSH NOTIFICATION
// ============================================================

async function sendPushToPatient({ token, title, body }) {

  if (!token) return;

  try {

    await admin.messaging().send({
      token,
      notification: { title, body },
      data: {
        target: "doctor_announcement",
        type: "doctor_announcement",
      },
    });

    console.log("📲 Push sent to patient");

  } catch (e) {

    console.error("❌ Push error:", e.message);
  }
}

// ============================================================
// 💾 SAVE IN-APP NOTIFICATION TO PATIENT
// ============================================================

async function saveNotificationToPatient({
  patientUid,
  title,
  body,
  announcement,
}) {

  if (!patientUid) return;

  const notifRef = admin
    .database()
    .ref(`notifications/${patientUid}`)
    .push();

  await notifRef.set({
    key: notifRef.key,
    title,
    body,
    to_key: patientUid,
    from_key: announcement.doctor_key || null,
    user_type: "patient",
    notification_type: "doctor_announcement",
    is_read: false,
    created_at: Date.now(),
    extra_data: {
      announcement_type: announcement.type,
      doctor_key: announcement.doctor_key || null,
      doctor_name: announcement.doctor_name || null,
    },
  });

  console.log(`✅ In-app notification saved → ${patientUid}`);
}

// ============================================================
// 🗓️ CONVERT ANNOUNCEMENT DATE → RESERVATION DATE
// Announcement stores: YYYY-MM-DD (e.g. 2026-05-26)
// Reservations are stored under: DD-MM-YYYY (e.g. 26-05-2026)
// ============================================================

function toReservationDate(announcementDate) {
  const parts = announcementDate.split("-");
  if (parts.length !== 3) return announcementDate;
  const [year, month, day] = parts;
  return `${day}-${month}-${year}`;
}

// ============================================================
// 🔍 GET ACTIVE PATIENTS FOR A DOCTOR ON A DATE
// ============================================================

async function getActivePatientsForDoctor({ doctorKey, date }) {

  try {

    // Convert from YYYY-MM-DD to DD-MM-YYYY to match Firebase reservation path
    const reservationDate = toReservationDate(date);

    console.log(
      `🗓️ Announcement date: ${date} → Reservation date: ${reservationDate}`
    );

    const snap = await admin
      .database()
      .ref(`doctors/${doctorKey}/reservations/${reservationDate}`)
      .once("value");

    if (!snap.exists()) {
      console.log(`📭 No reservations for ${doctorKey} on ${date}`);
      return [];
    }

    const reservations = snap.val();

    const cancelledStatuses = [
      "cancelled_by_user",
      "cancelled_by_assistant",
      "cancelled_by_doctor",
      "completed",
      "missed",
    ];

    const patients = [];

    Object.values(reservations).forEach((reservation) => {

      if (!reservation.patient_uid) return;

      if (cancelledStatuses.includes(reservation.status)) return;

      patients.push({
        uid: reservation.patient_uid,
        fcm: reservation.patient_fcm || null,
        name: reservation.patient_name || "مريض",
      });
    });

    console.log(`👥 Active patients found: ${patients.length}`);

    return patients;

  } catch (e) {

    console.error("❌ getActivePatients error:", e.message);
    return [];
  }
}

module.exports = {
  buildAnnouncementMessage,
  sendPushToPatient,
  saveNotificationToPatient,
  getActivePatientsForDoctor,
};
