const { onValueWritten } = require(
  "firebase-functions/v2/database"
);

const {

  handleNewOrder,

} = require("./orderNotifications");

const {

  handleOrderStatusChange,

} = require("./orderStatus");

// ============================================================
// 🔥 ORDER TRIGGER
// ============================================================

exports.onOrderUpdate =
  onValueWritten(

    {

      ref: "orders/{orderId}",

      instance:
        "link-b47c8-default-rtdb",
    },

    async (event) => {

      try {

        console.log(
          "🔥 ORDER FUNCTION TRIGGERED"
        );

        const before =
          event.data.before.val();

        const after =
          event.data.after.val();

        console.log(
          "📄 BEFORE:",
          JSON.stringify(before, null, 2)
        );

        console.log(
          "📄 AFTER:",
          JSON.stringify(after, null, 2)
        );

        // ====================================================
        // ❌ DELETED
        // ====================================================

        if (!after) {

          console.log(
            "❌ Order deleted"
          );

          return;
        }

        // ====================================================
        // 🆕 NEW ORDER
        // ====================================================

        await handleNewOrder({

          before,

          after,
        });

        // ====================================================
        // 🔄 STATUS CHANGE
        // ====================================================

        await handleOrderStatusChange({

          before,

          after,
        });

        console.log(
          "✅ ORDER FLOW FINISHED"
        );

      } catch (e) {

        console.error(
          "❌ ORDER TRIGGER ERROR:",
          e
        );
      }
    }
  );