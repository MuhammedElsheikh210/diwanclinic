const { onRequest } = require(
  "firebase-functions/v2/https"
);

const admin = require(
  "firebase-admin"
);

const axios = require("axios");

// ============================================================
// 📲 SEND WHATSAPP
// ============================================================

async function sendWhatsApp(
  to,
  msg
) {

  try {

    const res =
      await axios.post(

        "https://api.ultramsg.com/instance86174/messages/chat",

        new URLSearchParams({

          token:
            "zi9hxnjprdgdayfg",

          to: "+" + to,

          body: msg,
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
      res.data
    );

  } catch (e) {

    console.error(

      "❌ WhatsApp ERROR:",

      e.response?.data ||
        e.message
    );
  }
}

// ============================================================
// 📞 NORMALIZE PHONE
// ============================================================

function normalizePhone(
  phone
) {

  if (
    phone.startsWith("20")
  ) {

    return (
      "0" +
      phone.substring(2)
    );
  }

  return phone;
}

// ============================================================
// 🔥 WHATSAPP WEBHOOK
// ============================================================

const whatsappWebhook =
  onRequest(

    async (req, res) => {

      try {

        const data =
          req.body.data ||
          req.body;

        const phone =
          data?.from;

        const type =
          data?.type;

        console.log(

          "📩 Incoming:",

          JSON.stringify(
            data,
            null,
            2
          )
        );

        if (!phone) {

          console.log(
            "❌ No phone"
          );

          return res.send(
            "no phone"
          );
        }

        const db =
          admin.database();

        // ====================================================
        // 🔹 CLEAN PHONE
        // ====================================================

        let cleanPhone =
          phone.replace(
            "@c.us",
            ""
          );

        if (
          cleanPhone.startsWith(
            "+"
          )
        ) {

          cleanPhone =
            cleanPhone.substring(
              1
            );
        }

        const localPhone =
          normalizePhone(
            cleanPhone
          );

        console.log(
          "📞 localPhone:",
          localPhone
        );

        // ====================================================
        // 🔹 SESSION
        // ====================================================

        const sessionRef =
          db.ref(
            "users_sessions/" +
              cleanPhone
          );

        const snap =
          await sessionRef.once(
            "value"
          );

        let session =
          snap.val();

        if (!session) {

          session = {};
        }

        console.log(
          "📄 SESSION:",
          JSON.stringify(
            session,
            null,
            2
          )
        );

        // ====================================================
        // 🔥 TEXT / NON IMAGE
        // ====================================================

        if (
          type !== "image" &&
          type !== "document"
        ) {

          const text =
            (
              data?.body || ""
            )
              .trim()
              .toLowerCase();

          const normalizedText =
            text

              .replace(
                /١/g,
                "1"
              )

              .replace(
                /٢/g,
                "2"
              );

          console.log(
            "✍️ normalizedText:",
            normalizedText
          );

          // ==================================================
          // 🧾 WAITING CONFIRMATION
          // ==================================================

          if (

            session.step ===
              "calculated" &&

            session.activeOrderId
          ) {

            console.log(
              "🧾 WAITING CONFIRMATION FLOW"
            );

            const orderRef =
              db.ref(

                "orders/" +
                  session.activeOrderId
              );

            const orderSnap =
              await orderRef.once(
                "value"
              );

            const order =
              orderSnap.val();

            if (!order) {

              console.log(
                "❌ ORDER NOT FOUND"
              );

              return res.send(
                "no order"
              );
            }

            // ================================================
            // ✅ CONFIRM
            // ================================================

            const confirmValues = [

              "1",

              "موافق",

              "تمام",

              "yes",

              "ok",

              "confirm",
            ];

            if (

              confirmValues.includes(
                normalizedText
              )
            ) {

              console.log(
                "✅ ORDER CONFIRMED"
              );

              await orderRef.update({

                status:
                  "completed",

                completed_at:
                  Date.now(),
              });

            await orderRef.update({

              status:
                "completed",

              completed_at:
                Date.now(),
            });

              await sendWhatsApp(

                cleanPhone,

`✅ تم تأكيد الطلب بنجاح

🚚 طلبك خرج للتوصيل

⏱️ متوقع يوصل خلال 15 - 45 دقيقة

💙 شكراً لاستخدامك لينك`
              );

              return res.send(
                "confirmed"
              );
            }

            // ================================================
            // ❌ CANCEL
            // ================================================

            const cancelValues = [

              "2",

              "إلغاء",

              "الغاء",

              "cancel",

              "no",
            ];

            if (

              cancelValues.includes(
                normalizedText
              )
            ) {

              console.log(
                "❌ ORDER CANCELLED"
              );

              await orderRef.update({

                status:
                  "cancelled",

                cancel_reason:
                  "تم الإلغاء بواسطة العميل عبر واتساب",

                cancelled_at:
                  Date.now(),
              });

              await sessionRef.update({

                step:
                  "cancelled",

                activeOrderId:
                  null,

                updatedAt:
                  Date.now(),
              });

              await sendWhatsApp(

                cleanPhone,

`❌ تم إلغاء الطلب بنجاح

💙 لو حابب تطلب روشتة جديدة ابعت صورة الروشتة مباشرة`
              );

              return res.send(
                "cancelled"
              );
            }

            // ================================================
            // ⚠️ INVALID
            // ================================================

            console.log(
              "⚠️ INVALID CONFIRMATION RESPONSE"
            );

            await sendWhatsApp(

              cleanPhone,

`⚠️ الرد غير مفهوم

1️⃣ للموافقة على الطلب
2️⃣ لإلغاء الطلب`
            );

            return res.send(
              "invalid"
            );
          }

          // ==================================================
          // 🟡 WAITING PRESCRIPTION
          // ==================================================

          if (

            session.step ===
              "awaiting_prescription"
          ) {

            console.log(
              "🟡 WAITING PRESCRIPTION"
            );

            await sendWhatsApp(

              cleanPhone,

`📸 ابعت صورة الروشتة من فضلك

💙 وسيتم مراجعتها فوراً`
            );

            return res.send(
              "waiting image"
            );
          }

          // ==================================================
          // ✅ SESSION FINISHED
          // ==================================================

          if (

            session.step ===
              "completed" ||

            session.step ===
              "cancelled" ||

            session.step ===
              "delivered"
          ) {

            console.log(
              "✅ SESSION FINISHED"
            );

            // 🔥 لو مجرد كلام عادي
            // منردش كتير

            const casualTexts = [

              "تمام",

              "شكرا",

              "thanks",

              "ok",

              "hello",

              "hi",

              "👍",

              "❤️",
            ];

            if (
              casualTexts.includes(
                normalizedText
              )
            ) {

              return res.send(
                "ignored"
              );
            }

            await sendWhatsApp(

              cleanPhone,

`💙 لو حابب تطلب روشتة جديدة ابعت صورة الروشتة مباشرة

📱 ولتجربة أسرع ومتابعة أسهل للطلبات استخدم تطبيق لينك`
            );

            return res.send(
              "session finished"
            );
          }

          // ==================================================
          // 🟢 ORDER EXISTS
          // ==================================================

          if (

            session.step ===
              "in_order" &&

            session.activeOrderId
          ) {

            console.log(
              "🟢 ORDER EXISTS"
            );

            await sendWhatsApp(

              cleanPhone,

`✅ طلبك بالفعل قيد المراجعة

📸 لو حابب تضيف صورة تانية ابعتها هنا مباشرة`
            );

            return res.send(
              "order exists"
            );
          }

          // ==================================================
          // 🔵 OUTSIDE SESSION
          // ==================================================

          console.log(
            "🔵 OUTSIDE SESSION"
          );

          return res.send(
            "ignored"
          );
        }

      // ====================================================
      // 📸 IMAGE / DOCUMENT HANDLER
      // ====================================================

      const imageUrl =
        data?.media;

      console.log(

        "📸 MEDIA RECEIVED:",

        imageUrl
      );

      console.log(
        "📦 MEDIA TYPE:",
        type
      );

      if (!imageUrl) {

        console.log(
          "❌ NO MEDIA URL"
        );

        return res.send(
          "no image"
        );
      }

      // ====================================================
      // 🔥 RESET FINISHED SESSION
      // ====================================================

      if (

        session.step ===
          "completed" ||

        session.step ===
          "cancelled" ||

        session.step ===
          "delivered"
      ) {

        console.log(
          "🔄 RESETTING SESSION FOR NEW ORDER"
        );

      await sessionRef.update({

        step:
          "awaiting_prescription",

        activeOrderId:
          null,

        updatedAt:
          Date.now(),
      });

      console.log(
        "✅ SESSION RESET DONE"
      );

      session.step =
        "awaiting_prescription";

      session.activeOrderId =
        null;
      }

      // ====================================================
      // 🟡 ADD IMAGE TO EXISTING ORDER
      // ====================================================

      if (
        session.activeOrderId &&
        session.step === "in_order"
      ) {

        console.log(
          "🟡 ADD IMAGE TO EXISTING ORDER"
        );

        const orderRef = db.ref(
          "orders/" + session.activeOrderId
        );

        const orderSnap =
          await orderRef.once("value");

        const order = orderSnap.val();

        if (!order) {

          console.log(
            "❌ ORDER NOT FOUND"
          );

          return res.send(
            "order missing"
          );
        }

        const images = [

          order?.prescription_url_1,

          order?.prescription_url_2,

          order?.prescription_url_3,

          order?.prescription_url_4,

          order?.prescription_url_5,

        ].filter(Boolean);

        // ==================================================
        // 🛑 MAX IMAGES
        // ==================================================

        if (images.length >= 5) {

          await sendWhatsApp(
            cleanPhone,
            "⚠️ تم الوصول للحد الأقصى للصور المسموح بها"
          );

          return res.send("max images");
        }

        // ==================================================
        // ➕ ADD IMAGE
        // ==================================================

        images.push(imageUrl);

        await orderRef.update({

          prescription_url_1:
            images[0] || null,

          prescription_url_2:
            images[1] || null,

          prescription_url_3:
            images[2] || null,

          prescription_url_4:
            images[3] || null,

          prescription_url_5:
            images[4] || null,
        });

        console.log(
          "✅ IMAGE ADDED TO EXISTING ORDER"
        );

        await sendWhatsApp(

          cleanPhone,

          "📸 تم إضافة صورة جديدة للطلب 👍"
        );

        return res.send("ok");
      }

      // ====================================================
      // 🛑 NO ACTIVE SESSION
      // ====================================================

      if (
        session.step !==
        "awaiting_prescription"
      ) {

        console.log(
          "❌ NO ACTIVE SESSION"
        );

        await sendWhatsApp(

          cleanPhone,

      `⚠️ من فضلك اطلب الخدمة من التطبيق 💙`
        );

        return res.send(
          "no active session"
        );
      }

      // ====================================================
      // ❌ NO RESERVATION
      // ====================================================

      if (!session.reservationId) {

        console.log(
          "❌ NO RESERVATION ID"
        );

        await sendWhatsApp(

          cleanPhone,

      `⚠️ من فضلك اطلب الخدمة من التطبيق أو من العيادة أولاً 💙`
        );

        return res.send(
          "no reservation"
        );
      }

      // ====================================================
      // 🔍 GET RESERVATION
      // ====================================================

      console.log(
        "🔍 SEARCHING RESERVATION:",
        session.reservationId
      );

      const reservationsSnap =
        await db
          .ref("doctors")
          .once("value");

      let reservation = null;

      let doctorId = null;

      reservationsSnap.forEach(
        (doctorSnap) => {

          const doctorReservations =
            doctorSnap.child(
              "reservations"
            );

          doctorReservations.forEach(
            (dateSnap) => {

              dateSnap.forEach(
                (reservationSnap) => {

                  const r =
                    reservationSnap.val();

                  if (
                    r?.key ===
                    session.reservationId
                  ) {

                    reservation = r;

                    doctorId =
                      doctorSnap.key;
                  }
                }
              );
            }
          );
        }
      );

      if (!reservation) {

        console.log(
          "❌ RESERVATION NOT FOUND"
        );

        await sendWhatsApp(

          cleanPhone,

      `⚠️ تعذر العثور على بيانات الحجز

      من فضلك تواصل مع العيادة 💙`
        );

        return res.send(
          "reservation missing"
        );
      }

      console.log(
        "✅ RESERVATION FOUND"
      );

      // ====================================================
      // 🔍 GET PHARMACY
      // ====================================================

      const pharmacySnap =
        await db
          .ref("clients")
          .orderByChild("userType")
          .equalTo("pharmacy")
          .once("value");

      let pharmacy = null;

      pharmacySnap.forEach(
        (child) => {

          if (!pharmacy) {

            pharmacy =
              child.val();
          }
        }
      );

      if (!pharmacy) {

        console.log(
          "❌ NO PHARMACY FOUND"
        );

        await sendWhatsApp(

          cleanPhone,

      `⚠️ لا توجد صيدلية متاحة حالياً

      من فضلك حاول مرة أخرى لاحقاً 💙`
        );

        return res.send(
          "no pharmacy"
        );
      }

      // ====================================================
      // 🆕 CREATE ORDER
      // ====================================================

      const orderRef =
        db.ref("orders").push();

      const orderId =
        orderRef.key;

      console.log(
        "🆕 CREATING ORDER:",
        orderId
      );

      // ====================================================
      // 💾 ORDER DATA
      // ====================================================

      const orderData = {

        key:
          orderId,

        status:
          "approved",

        created_at:
          Date.now(),

        created_by:
          "whatsapp",

        // 👤 PATIENT

        patient_name:
          reservation.patient_name ||
          "",

        patient_phone:
          localPhone,

        patientuid:
          reservation.patient_uid ||
          "",

        patient_fcm_token:
          reservation.patient_fcm ||
          "",

        // 👨‍⚕️ RESERVATION

        reservation_key:
          reservation.key ||

          session.reservationId,

        doctor_key:
          doctorId ||

          "",

        clinic_key:
          reservation.clinic_key ||
          "",

        // 💊 PHARMACY

        pharmacy_uid:
          pharmacy.uid ||
          "",

        pharmacy_name:
          pharmacy.name ||
          "",

        pharmacy_phone:
          pharmacy.phone ||
          "",

        pharmacy_fcm_token:
          pharmacy.fcm_token ||
          "",

        // 📸 PRESCRIPTION

        prescription_url_1:
          imageUrl,

        // ⚙️

        isTransfered: 0,
      };

      // ====================================================
      // 💾 SAVE ORDER
      // ====================================================

      await orderRef.set(
        orderData
      );

      console.log(
        "✅ ORDER SAVED"
      );

      // ====================================================
      // 🔄 UPDATE SESSION
      // ====================================================

     await sessionRef.update({

       activeOrderId:
         orderId,

       reservationId:
         session.reservationId,

       step:
         "in_order",

       updatedAt:
         Date.now(),
     });

      console.log(
        "✅ SESSION UPDATED"
      );

      // ====================================================
      // 📲 SUCCESS MESSAGE
      // ====================================================

      await sendWhatsApp(

        cleanPhone,

      `📥 تم استلام الروشتة 👌

      ⏳ جاري التسعير خلال 5 دقائق 💙`
      );

      console.log(
        "✅ WHATSAPP SUCCESS MESSAGE SENT"
      );

      // ====================================================
      // ✅ DONE
      // ====================================================

      return res.send(
        "order created"
      );

      } catch (e) {

        console.error(
          "❌ WEBHOOK ERROR:",
          e
        );

        res
          .status(500)
          .send("error");
      }
    }
  );

module.exports = {

  whatsappWebhook,

  sendWhatsApp,

  normalizePhone,
};