const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

/**
 * HTTPS function — deletes a user from Firebase Auth.
 * Secured via Firebase ID token (admin-only, verified against RTDB).
 */
const deleteAuthUser = onRequest(
  { cors: false },
  async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    // ── Verify ID token ──────────────────────────────────────────
    const authHeader = req.headers.authorization ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing auth token" });
    }

    const idToken = authHeader.slice(7);
    let decoded;
    try {
      decoded = await admin.auth().verifyIdToken(idToken);
    } catch (_) {
      return res.status(401).json({ error: "Invalid auth token" });
    }

    // ── Verify caller is admin in RTDB ───────────────────────────
    const callerSnap = await admin
      .database()
      .ref(`clients/${decoded.uid}`)
      .once("value");

    const caller = callerSnap.val();
    if (!caller || caller.userType !== "admin") {
      return res.status(403).json({ error: "Admin access required" });
    }

    // ── Delete target user ───────────────────────────────────────
    const { uid } = req.body;
    if (!uid || typeof uid !== "string") {
      return res.status(400).json({ error: "uid is required" });
    }

    try {
      await admin.auth().deleteUser(uid);
      return res.status(200).json({ success: true, deletedUid: uid });
    } catch (e) {
      // User might already be deleted — treat as success
      if (e.code === "auth/user-not-found") {
        return res.status(200).json({ success: true, note: "user not found in Auth" });
      }
      return res.status(500).json({ error: e.message });
    }
  }
);

module.exports = { deleteAuthUser };
