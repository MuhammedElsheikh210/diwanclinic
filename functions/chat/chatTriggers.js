const { onValueCreated } = require("firebase-functions/v2/database");
const { handleNewChatMessage } = require("./chatNotifications");

// ============================================================
// 🔥 TRIGGER: pharmacy_chats/{pharmacyId}/chats/{chatId}/messages/{msgId}
// Fires ONLY when a new message is created (not updates).
// ============================================================

exports.onPharmacyChatMessage = onValueCreated(
  {
    ref: "pharmacy_chats/{pharmacyId}/chats/{chatId}/messages/{msgId}",
    instance: "link-b47c8-default-rtdb",
  },

  async (event) => {
    const message = event.data.val();
    if (!message) return;

    const { pharmacyId, chatId } = event.params;

    console.log("💬 PHARMACY CHAT MESSAGE:", pharmacyId, chatId);

    await handleNewChatMessage({ message, pharmacyId, chatId });
  }
);
