const admin = require("firebase-admin");

// ============================================================
// 📲 SEND PUSH NOTIFICATION
// ============================================================

async function sendPushNotification({
  token,
  title,
  body,
}) {

  try {

    if (!token) {

      console.log(
        "❌ TOKEN MISSING"
      );

      return;
    }

    console.log(
      "📲 Sending push:",
      token
    );

    const response =
      await admin.messaging().send({

        token,

        notification: {

          title,
          body,
        },
      });

    console.log(
      "✅ PUSH SUCCESS:",
      response
    );

  } catch (e) {

    console.error(
      "❌ PUSH ERROR:",
      e
    );
  }
}

// ============================================================
// 💾 SAVE NOTIFICATION
// ============================================================

async function saveNotification({
  uid,
  title,
  body,
  type,
  order,
  userType = "patient",
}) {

  if (!uid) {

    console.log(
      "❌ UID MISSING"
    );

    return;
  }

  const notifRef = admin
    .database()
    .ref(`notifications/${uid}`)
    .push();

  await notifRef.set({

    key: notifRef.key,

    title,
    body,

    to_key: uid,

    user_type: userType,

    notification_type: type,

    order_key:
      order?.key || null,

    reservation_key:
      order?.reservation_key || null,

    is_read: false,

    created_at: Date.now(),

    extra_data: order || null,
  });

  console.log(
    "✅ Notification saved"
  );
}

module.exports = {

  sendPushNotification,

  saveNotification,
};