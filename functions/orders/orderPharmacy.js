const admin = require("firebase-admin");

const {
  sendPushNotification,
  saveNotification,
} = require("./orderHelpers");

// ============================================================
// 🔔 NOTIFY PHARMACY ABOUT NEW ORDER
// ============================================================

async function notifyPharmacyAboutNewOrder({
  order,
}) {

  try {

    console.log(
      "🔥 notifyPharmacyAboutNewOrder START"
    );

    console.log(
      "📄 order:",
      JSON.stringify(order, null, 2)
    );

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    const patientName =
      order.patient_name ||
      "مريض جديد";

    const pharmacyToken =
      order.pharmacy_fcm_token;

    const pharmacyPhone =
      order.pharmacy_phone;

    const title =
      "💊 طلب روشتة جديد";

    const body =
`👤 ${patientName}

📦 طلب دواء جديد

📱 المصدر:
${order.created_by === "whatsapp"
  ? "واتساب"
  : "التطبيق"}`;

    // ========================================================
    // ❌ NO PHARMACY TOKEN
    // ========================================================

    if (!pharmacyToken) {

      console.log(
        "❌ NO PHARMACY TOKEN"
      );

      return;
    }

    // ========================================================
    // 📲 PUSH NOTIFICATION
    // ========================================================

    await sendPushNotification({

      token: pharmacyToken,

      title,

      body,
    });

    console.log(
      "📲 Pharmacy push sent"
    );

    // ========================================================
    // 💾 SAVE NOTIFICATION
    // ========================================================

    if (pharmacyPhone) {

      await saveNotification({

        uid: pharmacyPhone,

        title,

        body,

        type:
          "new_pharmacy_order",

        order,

        userType:
          "pharmacy",
      });

      console.log(
        "✅ Pharmacy notification saved"
      );
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