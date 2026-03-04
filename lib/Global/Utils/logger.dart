// import 'dart:developer' as developer;
//
// class SyncLogger {
//   static const bool enableLogs = true;
//
//   static void _log(
//       String level,
//       String tag,
//       String message, {
//         Object? error,
//         StackTrace? stackTrace,
//       }) {
//     if (!enableLogs) return;
//
//     final time = DateTime.now().toIso8601String();
//
//     developer.log(
//       "[$time] [$level] [$tag] $message",
//       name: "SYNC_ENGINE",
//       error: error,
//       stackTrace: stackTrace,
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   // 🔹 Levels
//   // ─────────────────────────────────────────────
//
//   static void info(String tag, String message) {
//     _log("INFO", tag, message);
//   }
//
//   static void success(String tag, String message) {
//     _log("SUCCESS", tag, message);
//   }
//
//   static void warning(String tag, String message) {
//     _log("WARNING", tag, message);
//   }
//
//   static void error(
//       String tag,
//       String message, [
//         Object? error,
//         StackTrace? stackTrace,
//       ]) {
//     _log("ERROR", tag, message, error: error, stackTrace: stackTrace);
//   }
//
//   // ─────────────────────────────────────────────
//   // 🔥 Performance Helper
//   // ─────────────────────────────────────────────
//
//   static Stopwatch startTimer() {
//     final stopwatch = Stopwatch()..start();
//     return stopwatch;
//   }
//
//   static void endTimer(String tag, String label, Stopwatch stopwatch) {
//     stopwatch.stop();
//     _log("PERFORMANCE", tag, "$label took ${stopwatch.elapsedMilliseconds} ms");
//   }
// }
