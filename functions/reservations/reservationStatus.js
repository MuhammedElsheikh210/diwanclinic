const {

  sendPushNotification,

  saveNotification,

  formatPhone,

  sendWhatsApp,

} = require("./reservationHelpers");

const {

  syncAssistantNotifications,

} = require("./reservationAssistants");

// ============================================================
// 📲 WHATSAPP MESSAGE BUILDER
// ============================================================

const ANDROID_LINK = "https://play.google.com/store/apps/details?id=com.elsheikh.marketingwhats";
const IOS_LINK     = "https://apps.apple.com/us/app/diwan-%D8%AF%D9%8A%D9%88%D8%A7%D9%86%D9%83/id6630387762";

function pickRandom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function buildAppLinks(phone) {
  return `

📱 حمّل تطبيق *لينك* وابدأ:

🔑 *بيانات الدخول:*
👤 اسم المستخدم: *${phone}*
🔐 كلمة السر: *${phone}*

⚠️ *مهم جداً — اتبع الخطوات دي:*
1️⃣ افتح التطبيق
2️⃣ اكتب رقمك *${phone}* في خانة اسم المستخدم
3️⃣ اكتب *نفس الرقم* في خانة كلمة السر
4️⃣ اضغط *دخول* — مش إنشاء حساب جديد ✅

📲 *أندرويد:*
${ANDROID_LINK}

🍎 *آيفون:*
${IOS_LINK}
📌 *مهم لمستخدمي آيفون:* لو اللينك مش بيظهر معاك، *احفظ الرقم ده في جهازك الأول* وبعدين افتح الرسالة تاني ✅

`;
}

function buildWhatsAppMessage({ status, patientName, doctorName, orderNum, patientCode, phone, hasApp }) {

  const name     = patientName  || "المريض";
  const doctor   = doctorName   || "الدكتور";
  const num      = orderNum     || "-";
  const codeLine = (patientCode && patientCode.trim())
    ? `\n🗂️ كود الحالة: *${patientCode}*`
    : "";
  const app      = hasApp ? "" : buildAppLinks(phone);

  // ============================================================
  // ✅ APPROVED — 8 نسخ
  // ============================================================

  if (status === "approved") {
    return pickRandom([

      `📌 تم تأكيد حجزك يا ${name} 💙\n\n👨‍⚕️ عند *د. ${doctor}*\n🔢 رقم الحجز: *${num}*${codeLine}\n\n📱 تابع دورك لحظة بلحظة من تطبيق *لينك*\n🔔 هيوصلك إشعار تلقائي كل ما اتخلصت حالة قبلك، وعند وصول الدكتور للعيادة\n\n🏠 تقدر كمان تحجز موعدك الجاي من بيتك من غير ما تيجي\n${app}`,

      `✅ حجزك اتأكد يا ${name} 🎉\n\n🩺 *د. ${doctor}* هيستناك\n🔢 رقم دورك: *${num}*${codeLine}\n\n👀 من تطبيق *لينك* شوف فاضلك كام مريض وانت في بيتك\n⏰ إنزل لما يكون دورك قرّب، مش هتحتاج تستنى زيادة في العيادة\n\n🏡 وللمرة الجاية تقدر تحجز من التطبيق براحتك\n${app}`,

      `مرحباً يا ${name} 👋\n\n✅ تم تأكيد موعدك عند *د. ${doctor}*\n📌 رقم الحجز: *${num}*${codeLine}\n\n⏱️ مش محتاج تستنى في العيادة من الأول\nافتح تطبيق *لينك* وتابع دورك وانت في مكانك\n🔔 إشعار تلقائي أول ما يقرب دورك\n\n🏠 حجز موعد الجاي متاح من التطبيق في أي وقت\n${app}`,

      `💙 أهلاً ${name}\n\nحجزك اتأكد ✅ عند *د. ${doctor}*\n🔢 الرقم التسلسلي: *${num}*${codeLine}\n\n🟢 تابع دورك على تطبيق *لينك* من راحتك\nالتطبيق بيبعتلك إشعار لحظي:\n• كل ما حالة تخلص قبلك\n• وعند وصول الدكتور للعيادة\n\n🏠 للحجز الجاي مش هتحتاج تيجي العيادة، تحجز من التطبيق\n${app}`,

      `السلام عليكم يا ${name} 🌿\n\nتم تأكيد موعدك ✅\n👨‍⚕️ *د. ${doctor}*\n🔢 رقم الحجز: *${num}*${codeLine}\n\n💡 نصيحة: متجيش العيادة من الأول وتستنى\nمن تطبيق *لينك* اتابع دورك وانت في بيتك، وهييجي إشعار أوتوماتيك لما يقرب وقتك\n\n📲 كمان تقدر تحجز للمرة الجاية من التطبيق بدون ما تيجي\n${app}`,

      `يا ${name}، حجزك اتأكد 💚\n\n👨‍⚕️ *د. ${doctor}* هيشوفك\n🔢 رقم الدور: *${num}*${codeLine}\n\n🔔 التطبيق بيبعتلك إشعار لحظي كل ما اتخلصت حالة قبلك\nمش محتاج تفضل مستني في العيادة من الأول\n\n📱 تطبيق *لينك* — تابع دورك وحجز الجاي من بيتك 🏡\n${app}`,

      `تأكيد الحجز - ${name} 📋\n\n🏥 *د. ${doctor}*\n🔢 رقمك: *${num}*${codeLine}\n\nتطبيق *لينك* هيوفرلك وقتك:\n📍 تعرف دورك وانت في بيتك\n🔔 إشعار فوري كل ما اتخلصت حالة\n🏠 حجز موعد جديد من أي مكان\n\n${app}`,

      `تمام يا ${name} ✅\n\nحجزك اتأكد عند *د. ${doctor}* 💙\n🔢 رقمك: *${num}*${codeLine}\n\nمش لازم تفضل قاعد في العيادة من الأول\nافتح تطبيق *لينك* وشوف فاضلك كام مريض من بيتك 🏠\n🔔 إشعار تلقائي عند وصول الدكتور وعند كل حالة تخلص\n\n${app}`,

    ]);
  }

  // ============================================================
  // 🎉 COMPLETED — ألف سلامة — 8 نسخ
  // ============================================================

  if (status === "completed") {
    return pickRandom([

      `🎉 ألف سلامة عليك يا ${name} 💙\n\n👨‍⚕️ من عيادة *د. ${doctor}*\nتم الانتهاء من الكشف بنجاح ✅\n\n🏠 المرة الجاية تقدر تحجز موعدك من بيتك من تطبيق *لينك* بدون ما تيجي العيادة\n🔔 التطبيق بيبعتلك إشعار لحظي وانت في الطريق\n${app}`,

      `سلامتك يا ${name} 🌿\n\nنتمنى لك الصحة والعافية دايماً 💚\nشكراً لزيارتك لـ *د. ${doctor}* ✅\n\n📲 للحجز الجاي، تطبيق *لينك* هيوفرلك وقتك\nحجز من بيتك وتابع دورك من غير انتظار 🏡\n${app}`,

      `ألف سلامة يا ${name} 🤍\n\nالكشف اتخلص بخير عند *د. ${doctor}* ✅\n\n🏠 محتاج زيارة تانية؟ حجز من تطبيق *لينك* من بيتك في أي وقت\nالتطبيق بيبعتلك إشعار تلقائي أول ما يقرب دورك 🔔\n${app}`,

      `💙 سلامتك يا ${name}\n\nتم إنهاء كشفك بنجاح عند *د. ${doctor}* ✅\n\n📱 تطبيق *لينك* جاهز دايماً:\n🏠 حجز موعد جديد من البيت\n🔔 متابعة دورك بإشعارات لحظية\n\n${app}`,

      `الحمد لله على السلامة يا ${name} 🌸\n\nانتهى كشفك بخير عند *د. ${doctor}* ✅\n\n📲 في حالة محتجت حجز تاني، افتح تطبيق *لينك* وحجز من بيتك 🛋️\nوهتتابع دورك وانت في راحتك من غير ما تستنى في العيادة\n${app}`,

      `🎊 ربنا يشفيك يا ${name}\n\nتم الكشف ✅ عند *د. ${doctor}*\n\n📍 للحجز الجاي مش لازم تيجي العيادة\nمن تطبيق *لينك* حجز وتابع دورك من مكانك 🏠\n${app}`,

      `سلامتك يا ${name} 💛\n\nزيارتك لـ *د. ${doctor}* اتخلصت بخير ✅\n\n🔔 للمرة الجاية:\nحجز من تطبيق *لينك* وتابع دورك لحظة بلحظة من بيتك\nهييجي إشعار أوتوماتيك وانت في الطريق 📲\n${app}`,

      `💙 ألف سلامة عليك يا ${name}\n\nمن عيادة *د. ${doctor}*، نتمنى لك الصحة والعافية 🌿\n\n🏠 للحجز الجاي تقدر تحجز من تطبيق *لينك* براحتك\nوهتتابع دورك لحظة بلحظة بدون ما تحتاج تستنى في العيادة من الأول\n${app}`,

    ]);
  }

  return null;
}

// ============================================================
// 🔔 HANDLE RESERVATION STATUS CHANGE
// ============================================================

async function handleReservationStatusChange({
  event,
  before,
  after,
  doctorId,
}) {

  try {

    // ========================================================
    // ✅ ONLY EXISTING RESERVATIONS
    // ========================================================

    if (!before) return;

    const beforeStatus = before.status;

    const afterStatus = after.status;

    // ========================================================
    // 🛑 SAME STATUS
    // ========================================================

    if (beforeStatus === afterStatus) {
      return;
    }

    const patientUid = after.patient_uid;

    const token = after.patient_fcm;

    if (!patientUid) return;

    // ========================================================
    // 🛑 PREVENT DUPLICATES
    // ========================================================

    const notificationKey =
      `notified_${afterStatus}`;

    if (after[notificationKey]) {
      return;
    }

    // ========================================================
    // 🧠 BUILD MESSAGE
    // ========================================================

    let title = "";

    let body = "";

    switch (afterStatus) {

      case "approved":

        title = "تم تأكيد الحجز ✅";

        body =
`حجزك رقم ${after.order_num} اتأكد 👍

⏳ تابع دورك من التطبيق لحظة بلحظة
🔔 هيوصلك إشعار كل ما اتخلصت حالة قبلك`;

        break;

      case "completed":

        title = "ألف سلامة عليك 💙";

        body =
`تم الانتهاء من الكشف بنجاح ✅

🏠 للحجز الجاي تقدر تحجز من التطبيق من بيتك
📲 تابع دورك بإشعارات لحظية بدون انتظار`;

        break;

      case "cancelled_by_doctor":

      case "cancelled_by_assistant":

      case "cancelled_by_user":

        title = "تم إلغاء الحجز";

        body =
          after.cancelReason ||
          "تم الإلغاء";

        break;

      default:
        return;
    }

    // ========================================================
    // 🔔 PUSH
    // ========================================================

    if (token) {

      await sendPushNotification({

        token,
        title,
        body,
      });
    }

    // ========================================================
    // 💾 SAVE
    // ========================================================

    await saveNotification({

      uid: patientUid,

      title,
      body,

      type: afterStatus,

      reservation: after,
    });

    // ========================================================
    // 📲 WHATSAPP
    // ========================================================

    if (afterStatus === "approved" || afterStatus === "completed") {

      const rawPhone = after.patient_phone;

      if (rawPhone) {

        const waMsg = buildWhatsAppMessage({
          status:      afterStatus,
          patientName: after.patient_name,
          doctorName:  after.doctor_name,
          orderNum:    after.order_num,
          patientCode: after.patient_code,
          phone:       rawPhone,
          hasApp:      !!(after.patient_fcm && after.patient_fcm.trim()),
        });

        if (waMsg) {
          await sendWhatsApp(formatPhone(rawPhone), waMsg);
        }
      }
    }

    // ========================================================
    // 🔄 SYNC ASSISTANTS
    // ========================================================

    await syncAssistantNotifications({

      doctorId,

      reservation: after,

      status: afterStatus,
    });

    // ========================================================
    // ✅ MARK AS NOTIFIED
    // ========================================================

    await event.data.after.ref.update({

      [notificationKey]: true,
    });

    console.log(
      "✅ Status notification sent"
    );

  } catch (e) {

    console.error(
      "❌ STATUS ERROR:",
      e
    );
  }
}

module.exports = {

  handleReservationStatusChange,
};