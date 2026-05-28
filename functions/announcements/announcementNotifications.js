const {
  buildAnnouncementMessage,
  sendPushToPatient,
  saveNotificationToPatient,
  getActivePatientsForDoctor,
} = require("./announcementHelpers");

// ============================================================
// 📣 HANDLE DOCTOR ANNOUNCEMENT → NOTIFY PATIENTS
// ============================================================

async function handleDoctorAnnouncement({
  announcement,
  doctorKey,
  date,
}) {

  try {

    console.log(
      `📣 handleDoctorAnnouncement: doctorKey=${doctorKey} date=${date} type=${announcement.type}`
    );

    // ========================================================
    // 🧠 BUILD MESSAGES
    // ========================================================

    const { title, body } =
      buildAnnouncementMessage(announcement);

    console.log(`📋 Title: ${title}`);
    console.log(`📋 Body: ${body}`);

    // ========================================================
    // 🔍 GET ACTIVE PATIENTS
    // ========================================================

    const patients = await getActivePatientsForDoctor({
      doctorKey,
      date,
    });

    if (!patients.length) {
      console.log("📭 No active patients to notify");
      return;
    }

    console.log(`📣 Notifying ${patients.length} patients`);

    // ========================================================
    // 🔁 NOTIFY EACH PATIENT
    // ========================================================

    for (const patient of patients) {

      console.log(`👤 Notifying patient: ${patient.uid}`);

      // Push
      await sendPushToPatient({
        token: patient.fcm,
        title,
        body,
      });

      // In-app
      await saveNotificationToPatient({
        patientUid: patient.uid,
        title,
        body,
        announcement,
      });
    }

    console.log("✅ All patients notified");

  } catch (e) {

    console.error("❌ handleDoctorAnnouncement ERROR:", e);
  }
}

module.exports = {
  handleDoctorAnnouncement,
};
