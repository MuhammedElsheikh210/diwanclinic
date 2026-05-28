const { onValueWritten } = require(
  "firebase-functions/v2/database"
);

const {
  handleDoctorAnnouncement,
} = require("./announcementNotifications");

// ============================================================
// 🔥 TRIGGER: doctors/{doctorKey}/doctor_announcements/{date}/{announcementId}
// Fires when a new announcement is created or updated.
// Only processes announcements where is_active: true.
// ============================================================

exports.onDoctorAnnouncementCreate = onValueWritten(
  {
    ref: "doctors/{doctorKey}/doctor_announcements/{date}/{announcementId}",
    instance: "link-b47c8-default-rtdb",
  },

  async (event) => {

    console.log("🔥 ANNOUNCEMENT FUNCTION TRIGGERED");

    const after = event.data.after.val();
    const before = event.data.before.val();

    // ── Skip deletions ──────────────────────────────────────
    if (!after) {
      console.log("🗑️ Deleted — skip");
      return;
    }

    // ── Only process active announcements ──────────────────
    if (after.is_active !== true) {
      console.log("🔕 Not active — skip");
      return;
    }

    // ── Skip deactivation updates (was active, now still active but same type)
    // We want to notify only on NEW active announcements, not edits to old ones
    if (
      before &&
      before.is_active === true &&
      before.type === after.type
    ) {
      console.log("🔄 Same type re-write — skip");
      return;
    }

    const doctorKey = event.params.doctorKey;
    const date = event.params.date;

    console.log(`📅 date: ${date}, doctorKey: ${doctorKey}`);

    await handleDoctorAnnouncement({
      announcement: after,
      doctorKey,
      date,
    });
  }
);
