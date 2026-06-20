const { onValueCreated } = require("firebase-functions/v2/database");
const { handleNewAssistantChatMessage } = require("./assistantChatNotifications");

// ============================================================
// 🔥 TRIGGER: assistant_chats/{doctorKey}/chats/{chatId}/messages/{msgId}
// Fires ONLY when a new message is created (not on updates).
// ============================================================

exports.onAssistantChatMessage = onValueCreated(
  {
    ref: "assistant_chats/{doctorKey}/chats/{chatId}/messages/{msgId}",
    instance: "link-b47c8-default-rtdb",
  },

  async (event) => {
    const message = event.data.val();
    if (!message) return;

    const { doctorKey, chatId } = event.params;

    console.log("💬 ASSISTANT CHAT MESSAGE:", doctorKey, chatId);

    await handleNewAssistantChatMessage({ message, doctorKey, chatId });
  }
);
