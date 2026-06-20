const axios = require("axios");
const admin = require("firebase-admin");
const { WHATSAPP_API_VERSION } = require("./whatsappConfig");

// ============================================================
// 📞 NORMALIZE PHONE — نتيجة: 201001234567 (بدون +)
// ============================================================

function cleanPhone(phone) {
  phone = phone.replace(/\+/g, "").trim();
  if (phone.startsWith("00")) phone = phone.substring(2);
  if (phone.startsWith("0"))  return "20" + phone.substring(1);
  if (!phone.startsWith("20")) return "20" + phone;
  return phone;
}

// ============================================================
// 📤 SEND TEXT MESSAGE — Meta Cloud API
// ============================================================
//
// process.env.WHATSAPP_ACCESS_TOKEN متاح داخل الـ function handler
// لأن الـ secrets متعلنة في خيارات كل function (secrets: [...])
// ============================================================

async function sendWhatsApp(to, msg) {
  const accessToken   = process.env.WHATSAPP_ACCESS_TOKEN;
  const phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  const phone         = cleanPhone(to);

  const res = await axios.post(
    `https://graph.facebook.com/${WHATSAPP_API_VERSION}/${phoneNumberId}/messages`,
    {
      messaging_product: "whatsapp",
      recipient_type:    "individual",
      to:                phone,
      type:              "text",
      text:              { body: msg },
    },
    {
      headers: {
        Authorization:  `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    }
  );

  console.log("✅ WhatsApp sent to", phone, "→", res.data?.messages?.[0]?.id);
}

// ============================================================
// 🖼️ DOWNLOAD MEDIA FROM META + UPLOAD TO FIREBASE STORAGE
// ============================================================
//
// Meta بتبعت media_id مش URL مباشر.
// الخطوات:
//   1. GET /v20.0/{media_id} + Authorization  → { url, mime_type }
//   2. GET {url}             + Authorization  → binary data   ← لازم Authorization هنا كمان
//   3. Upload to Firebase Storage             → public URL
// ============================================================

async function downloadAndUploadMedia(mediaId, filename) {
  const accessToken = process.env.WHATSAPP_ACCESS_TOKEN;

  // Step 1 — get temp URL from Meta
  const infoRes = await axios.get(
    `https://graph.facebook.com/${WHATSAPP_API_VERSION}/${mediaId}`,
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );

  const mediaUrl = infoRes.data.url;
  const mimeType = infoRes.data.mime_type || "image/jpeg";
  const ext      = mimeType.split("/")[1]  || "jpg";

  console.log("📸 Media URL retrieved, downloading...");

  // Step 2 — download binary (Authorization مطلوب هنا كمان)
  const downloadRes = await axios.get(mediaUrl, {
    headers:      { Authorization: `Bearer ${accessToken}` },
    responseType: "arraybuffer",
  });

  // Step 3 — upload to Firebase Storage
  const filePath = `prescriptions/${filename}.${ext}`;
  const bucket   = admin.storage().bucket();
  const file     = bucket.file(filePath);

  await file.save(Buffer.from(downloadRes.data), {
    metadata: { contentType: mimeType },
    public:   true,
  });

  const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
  console.log("✅ Media uploaded:", publicUrl);
  return publicUrl;
}

module.exports = {
  sendWhatsApp,
  downloadAndUploadMedia,
  cleanPhone,
};
