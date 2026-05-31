const admin = require("firebase-admin");

const {
  sendPushNotification,
  saveNotification,
} = require("./orderHelpers");

// ============================================================
// 🏥 FIND ALL PHARMACY STAFF BY pharmacy_key
// Source of truth: clients.pharmacy_id — no separate pharmacy_staff node
// ============================================================

async function findPharmacyStaff(db, pharmacyKey) {

  if (!pharmacyKey) return [];

  const snap = await db
    .ref("clients")
    .orderByChild("pharmacy_id")
    .equalTo(pharmacyKey)
    .once("value");

  const staff = [];

  snap.forEach((child) => {
    const val = child.val();
    if (val && val.userType === "pharmacy") {
      staff.push(val);
    }
  });

  return staff;
}

// ============================================================
// 🔔 NOTIFY ALL PHARMACY STAFF ABOUT NEW ORDER
// ============================================================

async function notifyPharmacyAboutNewOrder({
  order,
}) {

  try {

    console.log(
      "🔥 notifyPharmacyAboutNewOrder START"
    );

    const pharmacyKey =
      order.pharmacy_key ||
      order.pharmacy_uid ||
      order.pharmacy_id;

    if (!pharmacyKey) {
      console.log("❌ NO PHARMACY KEY in order");
      return;
    }

    const db = admin.database();

    // ── Fetch all staff for this pharmacy ──────────────────────
    const staffList = await findPharmacyStaff(db, pharmacyKey);

    if (staffList.length === 0) {
      console.log("⚠️ No pharmacy staff found for pharmacyKey:", pharmacyKey);
      return;
    }

    console.log(`👥 Found ${staffList.length} staff member(s) for pharmacy`);

    const patientName =
      order.patient_name || "مريض جديد";

    const title = "💊 طلب روشتة جديد";

    const body =
`👤 ${patientName}

📦 طلب دواء جديد

📱 المصدر:
${order.created_by === "whatsapp"
  ? "واتساب"
  : "التطبيق"}`;

    // ── Notify each staff member ───────────────────────────────
    for (const staff of staffList) {

      const staffUid   = staff.uid;
      const staffToken = staff.fcm_token;

      if (!staffUid) continue;

      // 1. FCM push (wakes device when in background)
      if (staffToken) {
        await sendPushNotification({
          token: staffToken,
          title,
          body,
        });
      }

      // 2. In-app notification (shown in notification inbox)
      await saveNotification({
        uid: staffUid,
        title,
        body,
        type: "new_pharmacy_order",
        order,
        userType: "pharmacy",
      });

      console.log(`✅ Notified staff uid=${staffUid}`);
    }

    console.log(
      "🔥 notifyPharmacyAboutNewOrder END"
    );

  } catch (e) {

    console.error(
      "❌ PHARMACY ORDER ERROR:",
      e
    );
  }
}

module.exports = {

  notifyPharmacyAboutNewOrder,
};
