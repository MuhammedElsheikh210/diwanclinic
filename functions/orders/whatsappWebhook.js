const { onRequest } = require("firebase-functions/v2/https");
const admin         = require("firebase-admin");

const { sendWhatsApp, downloadAndUploadMedia, cleanPhone } = require("../whatsapp/whatsappSender");
const {
  WHATSAPP_ACCESS_TOKEN,
  WHATSAPP_PHONE_NUMBER_ID,
  WHATSAPP_VERIFY_TOKEN,
} = require("../whatsapp/whatsappConfig");

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

const TERMINAL_STEPS = [
  STEP.ORDER_CONFIRMED,
  STEP.CANCELLED,
  STEP.DELIVERED,
  "completed",
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
// 📞 PHONE HELPERS
// ============================================================

function toLocalPhone(phone) {
  if (phone.startsWith("20")) return "0" + phone.substring(2);
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
    console.error("❌ findPatientByPhone ERROR:", e);
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
    const val       = child.val();
    const isPrimary = val.pharmacy_id === val.uid || !val.pharmacy_id;
    if (!pharmacy && isPrimary) pharmacy = val;
  });
  return pharmacy;
}

// ============================================================
// 📋 FIND RESERVATION BY KEY
// ============================================================

async function findReservationById(db, reservationId) {
  try {
    const snap = await db.ref("doctors").once("value");
    let reservation = null;
    let doctorId    = null;

    snap.forEach((doctorSnap) => {
      doctorSnap.child("reservations").forEach((dateSnap) => {
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
    console.error("❌ findReservationById ERROR:", e);
    return { reservation: null, doctorId: null };
  }
}

// ============================================================
// 🆕 CREATE ORDER
// ============================================================

async function createOrder(db, { imageUrl, localPhone, session, patient, reservation, doctorId, pharmacy }) {
  const orderRef = db.ref("orders").push();
  const orderId  = orderRef.key;

  await orderRef.set({
    key:        orderId,
    status:     "approved",
    created_at: Date.now(),
    created_by: "whatsapp",

    patient_name:
      reservation?.patient_name || patient?.name || "",
    patient_phone:
      localPhone,
    patientuid:
      reservation?.patient_uid || patient?.uid || "",
    patient_fcm_token:
      reservation?.patient_fcm || patient?.fcm_token || "",

    reservation_key:
      reservation?.key || session.reservationId || "",
    doctor_key:
      doctorId || session.doctorKey || "",
    clinic_key:
      reservation?.clinic_key || session.clinicKey || "",

    pharmacy_key:
      pharmacy.pharmacy_id || pharmacy.uid || "",
    pharmacy_uid:
      pharmacy.uid || "",
    pharmacy_name:
      pharmacy.name || "",
    pharmacy_phone:
      pharmacy.phone || "",
    pharmacy_fcm_token:
      pharmacy.fcm_token || "",

    prescription_url_1: imageUrl,
    isTransfered: 0,
  });

  console.log("✅ ORDER CREATED:", orderId);
  return orderId;
}

// ============================================================
// 🔥 WHATSAPP WEBHOOK
// ============================================================

const whatsappWebhook = onRequest(
  {
    secrets: [
      WHATSAPP_ACCESS_TOKEN,
      WHATSAPP_PHONE_NUMBER_ID,
      WHATSAPP_VERIFY_TOKEN,
    ],
  },
  async (req, res) => {

  // ——————————————————————————————————————————————————————————
  // ✅ GET — Webhook Verification
  // Meta بتبعت GET request مرة واحدة عشان تتأكد من الـ webhook
  // ——————————————————————————————————————————————————————————
  if (req.method === "GET") {
    const mode      = req.query["hub.mode"];
    const token     = req.query["hub.verify_token"];
    const challenge = req.query["hub.challenge"];

    if (mode === "subscribe" && token === process.env.WHATSAPP_VERIFY_TOKEN) {
      console.log("✅ Webhook verified");
      return res.status(200).send(challenge);
    }

    console.log("❌ Webhook verification failed");
    return res.status(403).send("Forbidden");
  }

  // ——————————————————————————————————————————————————————————
  // 📩 POST — Incoming Message
  // ——————————————————————————————————————————————————————————
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    // Meta بتحتاج 200 فوراً عشان ما تعيدش إرسال الـ event
    res.status(200).send("EVENT_RECEIVED");

    const body = req.body;

    if (body.object !== "whatsapp_business_account") return;

    const changes = body.entry?.[0]?.changes?.[0]?.value;
    if (!changes) return;

    const messages = changes.messages;
    if (!messages || messages.length === 0) return;

    const message    = messages[0];
    const type       = message.type;
    const from       = message.from; // e.g. "201234567890"

    console.log("📩 Incoming:", JSON.stringify(message, null, 2));

    const phone      = cleanPhone(from);
    const localPhone = toLocalPhone(phone);

    const db         = admin.database();
    const sessionRef = db.ref("users_sessions/" + phone);
    const snap       = await sessionRef.once("value");
    let   session    = snap.val() || {};
    const step       = session.step || "idle";

    console.log("📄 step:", step);

    // ——————————————————————————————————————————————————————
    // 🖼️ IMAGE / DOCUMENT
    // Meta بتبعت media_id مش URL مباشر — لازم نحمله أولاً
    // ——————————————————————————————————————————————————————
    if (type === "image" || type === "document") {
      const mediaId = type === "image"
        ? message.image?.id
        : message.document?.id;

      if (!mediaId) {
        console.log("❌ No media_id in message");
        return;
      }

      console.log("📸 Downloading media_id:", mediaId);

      let imageUrl;
      try {
        imageUrl = await downloadAndUploadMedia(
          mediaId,
          `${phone}_${Date.now()}`
        );
      } catch (e) {
        console.error("❌ Media download/upload error:", e.message);
        await sendWhatsApp(phone, "⚠️ حدث خطأ أثناء استلام الصورة، من فضلك أعد الإرسال");
        return;
      }

      // 🟡 Active order → add image to it
      if (step === STEP.IN_ORDER && session.activeOrderId) {
        console.log("🟡 ADD IMAGE TO EXISTING ORDER:", session.activeOrderId);

        const orderRef  = db.ref("orders/" + session.activeOrderId);
        const orderSnap = await orderRef.once("value");
        const order     = orderSnap.val();

        if (order) {
          const images = [
            order.prescription_url_1,
            order.prescription_url_2,
            order.prescription_url_3,
            order.prescription_url_4,
            order.prescription_url_5,
          ].filter(Boolean);

          if (images.length >= 5) {
            await sendWhatsApp(phone, "⚠️ تم الوصول للحد الأقصى للصور (5 صور)");
            return;
          }

          images.push(imageUrl);
          await orderRef.update({
            prescription_url_1: images[0] || null,
            prescription_url_2: images[1] || null,
            prescription_url_3: images[2] || null,
            prescription_url_4: images[3] || null,
            prescription_url_5: images[4] || null,
          });

          await sendWhatsApp(phone, "📸 تم إضافة صورة جديدة للطلب 👍");
          return;
        }
      }

      // 🆕 Any other state → ask for confirmation
      console.log("🆕 START NEW ORDER CONFIRM FLOW — prev step:", step);

      await sessionRef.update({
        step:            STEP.AWAITING_NEW_ORDER_CONFIRM,
        pendingImageUrl: imageUrl,
        activeOrderId:   null,
        updatedAt:       Date.now(),
      });

      await sendWhatsApp(phone,
`📸 تم استلام الروشتة بنجاح 👌

هل تريد طلب الدواء وتوصيله لحد البيت؟
🚚 بنفس سعر الصيدلية

1️⃣ نعم، أريد طلب الدواء
2️⃣ لا، شكراً`
      );
      return;
    }

    // ——————————————————————————————————————————————————————
    // ✍️ TEXT MESSAGE
    // ——————————————————————————————————————————————————————
    if (type !== "text") {
      console.log("⏭️ Unsupported message type:", type);
      return;
    }

    const rawText = (message.text?.body || "").trim().toLowerCase();
    const text    = rawText
      .replace(/١/g, "1")
      .replace(/٢/g, "2");

    console.log("✍️ text:", text, "| step:", step);

    // ——————————————————————————————————————————————————————
    // 🆕 AWAITING_NEW_ORDER_CONFIRM
    // ——————————————————————————————————————————————————————
    if (step === STEP.AWAITING_NEW_ORDER_CONFIRM) {
      if (CONFIRM_WORDS.includes(text)) {
        const pendingImageUrl = session.pendingImageUrl;

        if (!pendingImageUrl) {
          await sendWhatsApp(phone,
`⚠️ لم يتم العثور على الروشتة

من فضلك ابعت صورة الروشتة مجدداً 📸`
          );
          await sessionRef.update({ step: "idle", updatedAt: Date.now() });
          return;
        }

        const pharmacy = await findPharmacy(db);

        if (!pharmacy) {
          await sendWhatsApp(phone,
`⚠️ لا توجد صيدلية متاحة حالياً

من فضلك حاول مرة أخرى لاحقاً 💙`
          );
          return;
        }

        let reservation = null;
        let doctorId    = null;

        if (session.reservationId) {
          const found = await findReservationById(db, session.reservationId);
          reservation = found.reservation;
          doctorId    = found.doctorId;
        }

        let patient = null;
        if (!reservation) {
          patient = await findPatientByPhone(db, localPhone);
        }

        const orderId = await createOrder(db, {
          imageUrl: pendingImageUrl,
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

        await sendWhatsApp(phone,
`📥 تم استلام الروشتة ✅

⏳ جاري التسعير من الصيدلية
هيجيلك السعر خلال دقائق 💙

📸 لو عندك صور تانية للروشتة ابعتها هنا`
        );
        return;
      }

      if (CANCEL_WORDS.includes(text)) {
        await sessionRef.update({
          step:            "idle",
          pendingImageUrl: null,
          updatedAt:       Date.now(),
        });
        await sendWhatsApp(phone,
`❌ تم إلغاء الطلب

💙 لو احتجت أي حاجة ابعت صورة الروشتة هنا`
        );
        return;
      }

      await sendWhatsApp(phone,
`⚠️ الرد غير مفهوم

1️⃣ للموافقة وطلب الدواء
2️⃣ للإلغاء`
      );
      return;
    }

    // ——————————————————————————————————————————————————————
    // 💰 CALCULATED — waiting for customer confirmation
    // ——————————————————————————————————————————————————————
    if (step === STEP.CALCULATED && session.activeOrderId) {
      const orderRef  = db.ref("orders/" + session.activeOrderId);
      const orderSnap = await orderRef.once("value");
      const order     = orderSnap.val();

      if (!order || ["completed", "order_confirmed", "cancelled", "delivered"].includes(order.status)) {
        await sessionRef.update({
          step:      order?.status === "cancelled" ? STEP.CANCELLED : STEP.ORDER_CONFIRMED,
          updatedAt: Date.now(),
        });
        await sendWhatsApp(phone,
`💙 طلبك السابق اتنفذ بالفعل

📸 لو حابب تطلب روشتة جديدة ابعت صورة الروشتة هنا`
        );
        return;
      }

      if (CONFIRM_WORDS.includes(text)) {
        await orderRef.update({ status: "completed", completed_at: Date.now() });
        await sessionRef.update({ step: STEP.ORDER_CONFIRMED, updatedAt: Date.now() });
        await sendWhatsApp(phone,
`✅ تم تأكيد الطلب بنجاح 🎉

🚚 طلبك خرج للتوصيل
⏱️ متوقع يوصل خلال 15 - 45 دقيقة

💙 شكراً لاستخدامك لينك
📸 لو احتجت روشتة جديدة ابعتها هنا`
        );
        return;
      }

      if (CANCEL_WORDS.includes(text)) {
        await orderRef.update({
          status:        "cancelled",
          cancel_reason: "تم الإلغاء بواسطة العميل عبر واتساب",
          cancelled_at:  Date.now(),
        });
        await sessionRef.update({ step: STEP.CANCELLED, activeOrderId: null, updatedAt: Date.now() });
        await sendWhatsApp(phone,
`❌ تم إلغاء الطلب

💙 لو حابب تطلب روشتة جديدة
ابعت صورة الروشتة هنا مباشرة`
        );
        return;
      }

      await sendWhatsApp(phone,
`⚠️ الرد غير مفهوم

💰 إجمالي الطلب: ${order.total_order || "-"}

1️⃣ للموافقة على الطلب
2️⃣ لإلغاء الطلب`
      );
      return;
    }

    // ——————————————————————————————————————————————————————
    // 🟢 IN_ORDER
    // ——————————————————————————————————————————————————————
    if (step === STEP.IN_ORDER && session.activeOrderId) {
      await sendWhatsApp(phone,
`✅ طلبك قيد المراجعة من الصيدلية

📸 لو عندك صورة تانية للروشتة ابعتها هنا
⏳ هيجيلك السعر خلال دقائق 💙`
      );
      return;
    }

    // ——————————————————————————————————————————————————————
    // ✅ TERMINAL STATES
    // ——————————————————————————————————————————————————————
    if (TERMINAL_STEPS.includes(step)) {
      if (CASUAL_WORDS.includes(text)) return;

      await sendWhatsApp(phone,
`💙 أهلاً بك دائماً 😊

📸 لو محتاج تطلب روشتة جديدة
ابعت صورة الروشتة هنا وهنساعدك فوراً 🚚`
      );
      return;
    }

    // ——————————————————————————————————————————————————————
    // 🔵 IDLE / UNKNOWN
    // ——————————————————————————————————————————————————————
    await sendWhatsApp(phone,
`👋 أهلاً بك في خدمة توصيل الدواء 💙

📸 ابعت صورة الروشتة
وهنوصلك الدواء لحد البيت 🚚
بنفس سعر الصيدلية`
    );

  } catch (e) {
    console.error("❌ WEBHOOK ERROR:", e);
  }
});

module.exports = {
  whatsappWebhook,
};
