const admin = require("firebase-admin");

const {

  sendPushNotification,

  saveNotification,

} = require("./orderHelpers");

const {
  sendWhatsApp,
} = require("./whatsappWebhook");

// ============================================================
// 🔄 HANDLE ORDER STATUS CHANGE
// ============================================================

async function handleOrderStatusChange({
  before,
  after,
}) {

  try {

    console.log(
      "🔥 handleOrderStatusChange START"
    );

    if (!before || !after) {
      return;
    }

    // ========================================================
    // ✅ STATUS CHANGED ONLY
    // ========================================================

    if (
      before.status === after.status
    ) {

      console.log(
        "⏭️ Same status"
      );

      return;
    }

    const patientUid =
      after.patientuid;

    const token =
      after.patient_fcm_token;

    console.log(
      "📌 Status changed:",
      before.status,
      "➡",
      after.status
    );

    console.log(
      "📄 ORDER:",
      JSON.stringify(after, null, 2)
    );

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    let title = "";

    let body = "";

    switch (after.status) {

      // ======================================================
      // 🕓 PENDING
      // ======================================================

      case "pending":

        title =
          "تم استلام الروشتة";

        body =
`🛒 تم استلام طلبك وجاري مراجعته من الصيدلية 💙`;

        break;

      // ======================================================
      // 💰 PROCESSING
      // ======================================================

      case "processing":

        title =
          "جاري تسعير الروشتة";

        body =
`💰 جاري تسعير الروشتة الخاصة بك

⏳ هيجيلك السعر خلال لحظات`;

        break;

      // ======================================================
      // 🧾 CALCULATED
      // ======================================================

      case "calculated":

        title =
          "تم تسعير الروشتة";

        body =
`💵 إجمالي الطلب:
${after.total_order || "-"}

📱 افتح التطبيق وشوف تفاصيل الروشتة كاملة

🚚 بمجرد التأكيد هنبدأ التجهيز فورًا`;

        // ====================================================
        // 📲 WHATSAPP FLOW
        // ====================================================

        if (
          after.created_by === "whatsapp" &&
          after.patient_phone
        ) {

          try {

            console.log(
              "📲 WHATSAPP CALCULATED FLOW"
            );

            const db =
              admin.database();

            const whatsappPhone =
              after.patient_phone
                .replace(/^0/, "20");

            // 🔄 UPDATE SESSION

            await db
              .ref(
                "users_sessions/" +
                  whatsappPhone
              )
              .update({

                step:
                  "calculated",

                activeOrderId:
                  after.key,

                updatedAt:
                  Date.now(),
              });

            console.log(
              "✅ SESSION UPDATED TO CALCULATED"
            );

            // 📲 SEND WHATSAPP

            await sendWhatsApp(

              whatsappPhone,

`💵 تم تسعير الروشتة

💰 إجمالي الطلب:
${after.total_order || "-"}

1️⃣ للموافقة على الطلب
2️⃣ لإلغاء الطلب`
            );

            console.log(
              "✅ WHATSAPP PRICE SENT"
            );

          } catch (e) {

            console.error(
              "❌ WHATSAPP CALCULATED ERROR:",
              e
            );
          }
        }

        break;

      // ======================================================
      // ✅ CONFIRMED
      // ======================================================

      case "confirmed":

        title =
          "تم تأكيد الطلب";

        body =
`✅ تم تأكيد الطلب بنجاح

💊 جاري تجهيز الروشتة الآن`;

        break;

      // ======================================================
      // 📦 APPROVED
      // ======================================================

      case "approved":

        title =
          "تم استلام الروشتة";

        body =
`💰 جاري تسعير الروشتة الخاصة بك`;

        break;

      // ======================================================
      // 🚚 COMPLETED
      // ======================================================

      case "completed":

        title =
          "طلبك خرج للتوصيل";

        body =
`🚚 طلبك خرج للتوصيل

⏱️ متوقع يوصل خلال 15 - 45 دقيقة

شكراً لاستخدامك لينك 💙

${after.created_by === "whatsapp"

? `📱 المرة الجاية اطلب من التطبيق مباشرة واستفيد بالعروض والخصومات 👌`

: ""}`;

        // Sync session (covers case when staff confirm from dashboard)
        if (
          after.created_by === "whatsapp" &&
          after.patient_phone
        ) {
          try {
            const db = admin.database();
            const whatsappPhone =
              after.patient_phone.replace(/^0/, "20");
            await db
              .ref("users_sessions/" + whatsappPhone)
              .update({
                step: "order_confirmed",
                updatedAt: Date.now(),
              });
          } catch (e) {
            console.error("❌ SESSION SYNC completed ERROR:", e);
          }
        }

        break;

      // ======================================================
      // 🌸 DELIVERED
      // ======================================================

      case "delivered":

        title =
          "تم توصيل الطلب";

        body =
`🌸 تم توصيل الطلب بنجاح

ألف سلامة عليك 💙

${after.created_by === "whatsapp"

? `📱 المرة الجاية اطلب من التطبيق واستفيد بحفظ العناوين ومتابعة الطلب بسهولة 👌`

: ""}`;

        // Update session to delivered
        if (
          after.created_by === "whatsapp" &&
          after.patient_phone
        ) {
          try {
            const db = admin.database();
            const whatsappPhone =
              after.patient_phone.replace(/^0/, "20");
            await db
              .ref("users_sessions/" + whatsappPhone)
              .update({
                step: "delivered",
                updatedAt: Date.now(),
              });
            console.log("✅ SESSION updated to delivered");
          } catch (e) {
            console.error("❌ SESSION SYNC delivered ERROR:", e);
          }
        }

        break;

      // ======================================================
      // ❌ CANCELLED
      // ======================================================

      case "cancelled":

        title =
          "تم إلغاء الطلب";

        body =

          after.cancel_reason ||

          "❌ تم إلغاء الطلب";

        break;

      default:

        return;
    }

    // ========================================================
    // 📲 PUSH NOTIFICATION
    // ========================================================

    if (token) {

      await sendPushNotification({

        token,

        title,

        body,
      });

      console.log(
        "✅ PUSH SENT"
      );
    }

    // ========================================================
    // 💾 SAVE NOTIFICATION
    // ========================================================

    if (patientUid) {

      await saveNotification({

        uid: patientUid,

        title,

        body,

        type: after.status,

        order: after,
      });

      console.log(
        "✅ NOTIFICATION SAVED"
      );
    }

    console.log(
      "✅ Order notification completed"
    );

  } catch (e) {

    console.error(
      "❌ ORDER STATUS ERROR:",
      e
    );
  }
}

module.exports = {

  handleOrderStatusChange,
};