const {

  sendPushNotification,

  saveNotification,

} = require("./orderHelpers");

const {

  notifyPharmacyAboutNewOrder,

} = require("./orderPharmacy");

// ============================================================
// 🆕 HANDLE NEW ORDER
// ============================================================

async function handleNewOrder({
  before,
  after,
}) {

  try {

    console.log(
      "🔥 handleNewOrder START"
    );

    // ========================================================
    // ✅ NEW ORDER ONLY
    // ========================================================

    if (before || !after) {

      return;
    }

    console.log(
      "📦 NEW ORDER CREATED"
    );

    console.log(
      "📄 ORDER:",
      JSON.stringify(after, null, 2)
    );

    const patientUid =
      after.patientuid;

    const token =
      after.patient_fcm_token;

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    const patientName =
      after.patient_name ||
      "مريض";

    const createdBy =
      after.created_by ===
      "whatsapp"

        ? "واتساب"

        : "التطبيق";

    const title =
      "💊 تم استلام الروشتة";

    const body =
`📥 تم استلام الروشتة بنجاح

⏳ جاري مراجعة الطلب الآن

📱 طريقة الطلب:
${createdBy}

💙 شكراً لاستخدام لينك`;

    // ========================================================
    // 📲 PATIENT PUSH
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

        type:
          after.status ||
          "pending",

        order: after,
      });

      console.log(
        "✅ Patient notified"
      );
    }

    // ========================================================
    // 💊 PHARMACY NOTIFICATION
    // ========================================================
    // Gate on pharmacy_key (always set at order creation) — NOT on
    // pharmacy_fcm_token, which belongs to one user only.
    // notifyPharmacyAboutNewOrder queries Firebase by pharmacy_id
    // and notifies ALL staff members.

    const pharmacyKey =
      after.pharmacy_key ||
      after.pharmacy_uid ||
      after.pharmacy_id;

    if (pharmacyKey) {

      await notifyPharmacyAboutNewOrder({

        order: after,
      });
    }

    console.log(
      "🔥 handleNewOrder END"
    );

  } catch (e) {

    console.error(
      "❌ NEW ORDER ERROR:",
      e
    );
  }
}

module.exports = {

  handleNewOrder,
};