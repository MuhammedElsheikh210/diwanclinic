// ============================================================
// WhatsApp Business Cloud API — Secrets & Config
// ============================================================
//
// ⚠️ الـ Tokens دي حساسة — اتحطش في الكود مطلقاً
//
// خطوات الإعداد:
// 1. firebase functions:secrets:set WHATSAPP_ACCESS_TOKEN
// 2. firebase functions:secrets:set WHATSAPP_PHONE_NUMBER_ID
// 3. firebase functions:secrets:set WHATSAPP_VERIFY_TOKEN
//
// القيم دي بتيجي من Meta Developer Console:
//   → WhatsApp > API Setup > Phone Number ID
//   → WhatsApp > API Setup > Access Token (System User Permanent)
//   → VERIFY_TOKEN: اختار أي string سري أنت
// ============================================================

const { defineSecret } = require("firebase-functions/params");

const WHATSAPP_ACCESS_TOKEN    = defineSecret("WHATSAPP_ACCESS_TOKEN");
const WHATSAPP_PHONE_NUMBER_ID = defineSecret("WHATSAPP_PHONE_NUMBER_ID");
const WHATSAPP_VERIFY_TOKEN    = defineSecret("WHATSAPP_VERIFY_TOKEN");

const WHATSAPP_API_VERSION = "v20.0";

module.exports = {
  WHATSAPP_ACCESS_TOKEN,
  WHATSAPP_PHONE_NUMBER_ID,
  WHATSAPP_VERIFY_TOKEN,
  WHATSAPP_API_VERSION,
};
