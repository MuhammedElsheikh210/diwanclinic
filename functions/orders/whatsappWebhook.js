const { onRequest } = require(
  "firebase-functions/v2/https"
);

const admin = require(
  "firebase-admin"
);

const axios = require("axios");

// ============================================================
// 📌 SESSION STEP CONSTANTS
// ============================================================

const STEP = {
  AWAITING_PRESCRIPTION:      "awaiting_prescription",
  AWAITING_NEW_ORDER_CONFIRM: "awaiting_new_order_confirm",
  IN_ORDER:                   "in_order",
  CALCULATED:                 "calculated",
  ORDER_CONFIRMED:            "order_confirmed",
  CANCELLED:                  "cancelled",
  DELIVERED:                  "delivered",
};

// Steps where a new prescription cycle can start
const TERMINAL_STEPS = [
  STEP.ORDER_CONFIRMED,
  STEP.CANCELLED,
  STEP.DELIVERED,
  "completed", // legacy compat
];

const CONFIRM_WORDS = [
  "1", "موافق", "تمام", "yes", "ok",
  "confirm", "أيوه", "ايوه", "نعم",
];

const CANCEL_WORDS = [
  "2", "إلغاء", "الغاء", "cancel", "no", "لا",
];

const CASUAL_WORDS = [
  "شكرا", "شكراً", "thanks",
  "hello", "hi", "👍", "❤️", "ماشي",
];

// ============================================================
// 📲 SEND WHATSAPP
// ============================================================

async function sendWhatsApp(to, msg) {
  try {

    const result = await axios.post(

      "https://api.ultramsg.com/instance86174/messages/chat",

      new URLSearchParams({
        token: "zi9hxnjprdgdayfg",
        to:    "+" + to,
        body:  msg,
      }),

      {
        headers: {
          "Content-Type":
            "application/x-www-form-urlencoded",
        },
      }
    );

    console.log(
      "✅ WhatsApp sent:",
      result.data
    );

  } catch (e) {

    console.error(
      "❌ WhatsApp ERROR:",
      e.response?.data || e.message
    );
  }
}

// ============================================================
// 📞 NORMALIZE PHONE  (20XXXXXXXX → 0XXXXXXXX)
// ============================================================

function normalizePhone(phone) {

  if (phone.startsWith("20")) {
    return "0" + phone.substring(2);
  }

  return phone;
}

// ============================================================
// 👤 FIND PATIENT BY PHONE
// ============================================================

async function findPatientByPhone(db, localPhone) {

  try {

    const snap = await db
      .ref("clients")
      .orderByChild("phone")
      .equalTo(localPhone)
      .once("value");

    let patient = null;

    snap.forEach((child) => {
      if (!patient) patient = child.val();
    });

    return patient;

  } catch (e) {

    console.error(
      "❌ findPatientByPhone ERROR:",
      e
    );

    return null;
  }
}

// ============================================================
// 🏥 FIND PHARMACY
// ============================================================

async function findPharmacy(db) {

  const snap = await db
    .ref("clients")
    .orderByChild("userType")
    .equalTo("pharmacy")
    .once("value");

  let pharmacy = null;

  snap.forEach((child) => {
    if (!pharmacy) pharmacy = child.val();
  });

  return pharmacy;
}

// ============================================================
// 📋 FIND RESERVATION BY KEY
// ============================================================

async function findReservationById(
  db,
  reservationId
) {

  try {

    const snap = await db
      .ref("doctors")
      .once("value");

    let reservation = null;
    let doctorId    = null;

    snap.forEach((doctorSnap) => {

      doctorSnap
        .child("reservations")
        .forEach((dateSnap) => {

          dateSnap.forEach((rSnap) => {

            const r = rSnap.val();

            if (r?.key === reservationId) {
              reservation = r;
              doctorId    = doctorSnap.key;
            }
          });
        });
    });

    return { reservation, doctorId };

  } catch (e) {

    console.error(
      "❌ findReservationById ERROR:",
      e
    );

    return {
      reservation: null,
      doctorId:    null,
    };
  }
}

// ============================================================
// 🆕 CREATE ORDER
// ============================================================

async function createOrder(db, {
  imageUrl,
  localPhone,
  session,
  patient,
  reservation,
  doctorId,
  pharmacy,
}) {

  const orderRef = db.ref("orders").push();
  const orderId  = orderRef.key;

  await orderRef.set({

    key:        orderId,
    status:     "approved",
    created_at: Date.now(),
    created_by: "whatsapp",

    // Patient
    patient_name:
      reservation?.patient_name ||
      patient?.name             || "",

    patient_phone:
      localPhone,

    patientuid:
      reservation?.patient_uid ||
      patient?.uid             || "",

    patient_fcm_token:
      reservation?.patient_fcm ||
      patient?.fcm_token       || "",

    // Reservation context (optional for universal flow)
    reservation_key:
      reservation?.key     ||
      session.reservationId || "",

    doctor_key:
      doctorId            ||
      session.doctorKey   || "",

    clinic_key:
      reservation?.clinic_key ||
      session.clinicKey       || "",

    // Pharmacy
    pharmacy_uid:
      pharmacy.uid       || "",

    pharmacy_name:
      pharmacy.name      || "",

    pharmacy_phone:
      pharmacy.phone     || "",

    pharmacy_fcm_token:
      pharmacy.fcm_token || "",

    // Prescription
    prescription_url_1: imageUrl,

    isTransfered: 0,
  });

  console.log(
    "✅ ORDER CREATED:",
    orderId
  );

  return orderId;
}

// ============================================================
// 🔥 WHATSAPP WEBHOOK
// ============================================================

const whatsappWebhook = onRequest(

  async (req, res) => {

    try {

      const data  = req.body.data || req.body;
      const phone = data?.from;
      const type  = data?.type;

      console.log(
        "📩 Incoming:",
        JSON.stringify(data, null, 2)
      );

      if (!phone) {
        console.log("❌ No phone");
        return res.send("no phone");
      }

      const db = admin.database();

      // ======================================================
      // 📞 PHONE NORMALIZATION
      // ======================================================

      let cleanPhone = phone.replace("@c.us", "");

      if (cleanPhone.startsWith("+")) {
        cleanPhone = cleanPhone.substring(1);
      }

      const localPhone = normalizePhone(cleanPhone);

      console.log(
        "📞 cleanPhone:", cleanPhone,
        "| localPhone:", localPhone
      );

      // ======================================================
      // 📋 SESSION
      // ======================================================

      const sessionRef = db.ref(
        "users_sessions/" + cleanPhone
      );

      const snap    = await sessionRef.once("value");
      let   session = snap.val() || {};
      const step    = session.step || "idle";

      console.log(
        "📄 step:", step,
        "| session:", JSON.stringify(session)
      );

      // ======================================================
      // 📸 IMAGE / DOCUMENT
      // ======================================================

      if (
        type === "image" ||
        type === "document"
      ) {

        const imageUrl = data?.media;

        console.log(
          "📸 MEDIA URL:", imageUrl,
          "| TYPE:", type
        );

        if (!imageUrl) {
          console.log("❌ NO MEDIA URL");
          return res.send("no image");
        }

        // ——————————————————————————————————————————————
        // 🟡 Active order → add image to it
        // ——————————————————————————————————————————————

        if (
          step === STEP.IN_ORDER &&
          session.activeOrderId
        ) {

          console.log(
            "🟡 ADD IMAGE TO EXISTING ORDER:",
            session.activeOrderId
          );

          const orderRef =
            db.ref("orders/" + session.activeOrderId);

          const orderSnap =
            await orderRef.once("value");

          const order = orderSnap.val();

          if (order) {

            const images = [
              order.prescription_url_1,
              order.prescription_url_2,
              order.prescription_url_3,
              order.prescription_url_4,
              order.prescription_url_5,
            ].filter(Boolean);

            if (images.length >= 5) {

              await sendWhatsApp(
                cleanPhone,
                "⚠️ تم الوصول للحد الأقصى للصور (5 صور)"
              );

              return res.send("max images");
            }

            images.push(imageUrl);

            await orderRef.update({
              prescription_url_1: images[0] || null,
              prescription_url_2: images[1] || null,
              prescription_url_3: images[2] || null,
              prescription_url_4: images[3] || null,
              prescription_url_5: images[4] || null,
            });

            await sendWhatsApp(
              cleanPhone,
              "📸 تم إضافة صورة جديدة للطلب 👍"
            );

            return res.send("image added");
          }

          // Order not found — fall through to new order flow
          console.log(
            "⚠️ Order not found, starting new order flow"
          );
        }

        // ——————————————————————————————————————————————
        // 🆕 All other states → ask for confirmation first
        // ——————————————————————————————————————————————

        console.log(
          "🆕 START NEW ORDER CONFIRM FLOW — prev step:",
          step
        );

        await sessionRef.update({
          step:            STEP.AWAITING_NEW_ORDER_CONFIRM,
          pendingImageUrl: imageUrl,
          activeOrderId:   null,
          updatedAt:       Date.now(),
        });

        await sendWhatsApp(
          cleanPhone,

`📸 تم استلام الروشتة بنجاح 👌

هل تريد طلب الدواء وتوصيله لحد البيت؟
🚚 بنفس سعر الصيدلية

1️⃣ نعم، أريد طلب الدواء
2️⃣ لا، شكراً`
        );

        return res.send("awaiting new order confirm");
      }

      // ======================================================
      // ✍️ TEXT MESSAGE
      // ======================================================

      const rawText = (data?.body || "")
        .trim()
        .toLowerCase();

      const text = rawText
        .replace(/١/g, "1")
        .replace(/٢/g, "2");

      console.log(
        "✍️ text:", text,
        "| step:", step
      );

      // ——————————————————————————————————————————————————————
      // 🆕 AWAITING_NEW_ORDER_CONFIRM
      // ——————————————————————————————————————————————————————

      if (step === STEP.AWAITING_NEW_ORDER_CONFIRM) {

        console.log(
          "🆕 AWAITING NEW ORDER CONFIRM FLOW"
        );

        // ✅ CONFIRM
        if (CONFIRM_WORDS.includes(text)) {

          console.log("✅ NEW ORDER CONFIRMED");

          const pendingImageUrl =
            session.pendingImageUrl;

          if (!pendingImageUrl) {

            await sendWhatsApp(
              cleanPhone,

`⚠️ لم يتم العثور على الروشتة

من فضلك ابعت صورة الروشتة مجدداً 📸`
            );

            await sessionRef.update({
              step:      "idle",
              updatedAt: Date.now(),
            });

            return res.send("no pending image");
          }

          // Get pharmacy
          const pharmacy = await findPharmacy(db);

          if (!pharmacy) {

            await sendWhatsApp(
              cleanPhone,

`⚠️ لا توجد صيدلية متاحة حالياً

من فضلك حاول مرة أخرى لاحقاً 💙`
            );

            return res.send("no pharmacy");
          }

          // Get reservation data if available
          let reservation = null;
          let doctorId    = null;

          if (session.reservationId) {

            const found = await findReservationById(
              db,
              session.reservationId
            );

            reservation = found.reservation;
            doctorId    = found.doctorId;
          }

          // Fallback: find patient by phone (universal flow)
          let patient = null;

          if (!reservation) {
            patient = await findPatientByPhone(
              db,
              localPhone
            );
          }

          // Create order
          const orderId = await createOrder(db, {
            imageUrl:    pendingImageUrl,
            localPhone,
            session,
            patient,
            reservation,
            doctorId,
            pharmacy,
          });

          await sessionRef.update({
            step:            STEP.IN_ORDER,
            activeOrderId:   orderId,
            pendingImageUrl: null,
            updatedAt:       Date.now(),
          });

          await sendWhatsApp(
            cleanPhone,

`📥 تم استلام الروشتة ✅

⏳ جاري التسعير من الصيدلية
هيجيلك السعر خلال دقائق 💙

📸 لو عندك صور تانية للروشتة ابعتها هنا`
          );

          return res.send("order created");
        }

        // ❌ CANCEL
        if (CANCEL_WORDS.includes(text)) {

          console.log("❌ NEW ORDER CANCELLED");

          await sessionRef.update({
            step:            "idle",
            pendingImageUrl: null,
            updatedAt:       Date.now(),
          });

          await sendWhatsApp(
            cleanPhone,

`❌ تم إلغاء الطلب

💙 لو احتجت أي حاجة ابعت صورة الروشتة هنا`
          );

          return res.send("new order cancelled");
        }

        // ⚠️ INVALID
        await sendWhatsApp(
          cleanPhone,

`⚠️ الرد غير مفهوم

1️⃣ للموافقة وطلب الدواء
2️⃣ للإلغاء`
        );

        return res.send("invalid");
      }

      // ——————————————————————————————————————————————————————
      // 💰 CALCULATED — price sent, waiting for confirmation
      // ——————————————————————————————————————————————————————

      if (
        step === STEP.CALCULATED &&
        session.activeOrderId
      ) {

        console.log("💰 CALCULATED FLOW");

        const orderRef =
          db.ref("orders/" + session.activeOrderId);

        const orderSnap =
          await orderRef.once("value");

        const order = orderSnap.val();

        // Guard: order already finished — fix stuck session
        if (
          !order ||
          [
            "completed",
            "order_confirmed",
            "cancelled",
            "delivered",
          ].includes(order.status)
        ) {

          console.log(
            "⚠️ ORDER ALREADY DONE — fixing stuck session"
          );

          await sessionRef.update({
            step:
              order?.status === "cancelled"
                ? STEP.CANCELLED
                : STEP.ORDER_CONFIRMED,
            updatedAt: Date.now(),
          });

          await sendWhatsApp(
            cleanPhone,

`💙 طلبك السابق اتنفذ بالفعل

📸 لو حابب تطلب روشتة جديدة ابعت صورة الروشتة هنا`
          );

          return res.send("stuck session fixed");
        }

        // ✅ CONFIRM
        if (CONFIRM_WORDS.includes(text)) {

          console.log("✅ ORDER CONFIRMED BY CUSTOMER");

          await orderRef.update({
            status:       "completed",
            completed_at: Date.now(),
          });

          // ✅ KEY FIX: update session so we don't loop
          await sessionRef.update({
            step:      STEP.ORDER_CONFIRMED,
            updatedAt: Date.now(),
          });

          await sendWhatsApp(
            cleanPhone,

`✅ تم تأكيد الطلب بنجاح 🎉

🚚 طلبك خرج للتوصيل
⏱️ متوقع يوصل خلال 15 - 45 دقيقة

💙 شكراً لاستخدامك لينك
📸 لو احتجت روشتة جديدة ابعتها هنا`
          );

          return res.send("confirmed");
        }

        // ❌ CANCEL
        if (CANCEL_WORDS.includes(text)) {

          console.log("❌ ORDER CANCELLED BY CUSTOMER");

          await orderRef.update({
            status:        "cancelled",
            cancel_reason: "تم الإلغاء بواسطة العميل عبر واتساب",
            cancelled_at:  Date.now(),
          });

          await sessionRef.update({
            step:          STEP.CANCELLED,
            activeOrderId: null,
            updatedAt:     Date.now(),
          });

          await sendWhatsApp(
            cleanPhone,

`❌ تم إلغاء الطلب

💙 لو حابب تطلب روشتة جديدة
ابعت صورة الروشتة هنا مباشرة`
          );

          return res.send("cancelled");
        }

        // ⚠️ INVALID
        await sendWhatsApp(
          cleanPhone,

`⚠️ الرد غير مفهوم

💰 إجمالي الطلب: ${order.total_order || "-"}

1️⃣ للموافقة على الطلب
2️⃣ لإلغاء الطلب`
        );

        return res.send("invalid");
      }

      // ——————————————————————————————————————————————————————
      // 🟢 IN_ORDER — order under pharmacy review
      // ——————————————————————————————————————————————————————

      if (
        step === STEP.IN_ORDER &&
        session.activeOrderId
      ) {

        console.log("🟢 IN_ORDER FLOW");

        await sendWhatsApp(
          cleanPhone,

`✅ طلبك قيد المراجعة من الصيدلية

📸 لو عندك صورة تانية للروشتة ابعتها هنا
⏳ هيجيلك السعر خلال دقائق 💙`
        );

        return res.send("order exists");
      }

      // ——————————————————————————————————————————————————————
      // ✅ TERMINAL STATES — all done
      // ——————————————————————————————————————————————————————

      if (TERMINAL_STEPS.includes(step)) {

        console.log("✅ TERMINAL STATE:", step);

        if (CASUAL_WORDS.includes(text)) {
          return res.send("ignored");
        }

        await sendWhatsApp(
          cleanPhone,

`💙 أهلاً بك دائماً 😊

📸 لو محتاج تطلب روشتة جديدة
ابعت صورة الروشتة هنا وهنساعدك فوراً 🚚`
        );

        return res.send("session finished");
      }

      // ——————————————————————————————————————————————————————
      // 🔵 IDLE / UNKNOWN — invite to send prescription
      // ——————————————————————————————————————————————————————

      console.log("🔵 IDLE/UNKNOWN STATE:", step);

      await sendWhatsApp(
        cleanPhone,

`👋 أهلاً بك في خدمة توصيل الدواء 💙

📸 ابعت صورة الروشتة
وهنوصلك الدواء لحد البيت 🚚
بنفس سعر الصيدلية + توصيل مجاني`
      );

      return res.send("idle");

    } catch (e) {

      console.error(
        "❌ WEBHOOK ERROR:",
        e
      );

      res.status(500).send("error");
    }
  }
);

module.exports = {

  whatsappWebhook,

  sendWhatsApp,

  normalizePhone,
};
