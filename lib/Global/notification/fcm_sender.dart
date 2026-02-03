import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// 🔹 Responsible for sending notifications via Firebase Cloud Messaging (v1 API)
class FcmSenderService {
  final String projectId;
  final String serviceAccountPath;

  FcmSenderService({required this.projectId, required this.serviceAccountPath});

  /// 🔑 Load JSON key and get OAuth token
  Future<String> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(serviceAccountPath);
      final jsonData = json.decode(jsonString);
      final credentials = ServiceAccountCredentials.fromJson(jsonData);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(credentials, scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      throw Exception("❌ Failed to load service account: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Send notification to a topic
  // ---------------------------------------------------------------------------
  Future<String> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final accessToken = await _getAccessToken();
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final payload = {
      "message": {
        "topic": topic,
        "notification": {"title": title, "body": body},
        "android": {
          "priority": "HIGH",
          "notification": {
            "channel_id": "high_importance_channel",
            "sound": "default",
          },
        },
        "apns": {
          "headers": {"apns-priority": "10"},
          "payload": {
            "aps": {
              "alert": {"title": title, "body": body},
              "sound": "default",
            },
          },
        },
        "data": data ?? {},
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return "✅ Topic notification sent successfully (with sound)!";
    } else {
      return "❌ Failed: ${response.statusCode} - ${response.body}";
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Send notification to a single device token
  // ---------------------------------------------------------------------------
  Future<String> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final accessToken = await _getAccessToken();
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final payload = {
      "message": {
        "token": token,
        "notification": {"title": title, "body": body},
        "android": {
          "priority": "HIGH",
          "notification": {
            "channel_id": "high_importance_channel",
            "sound": "default",
          },
        },
        "apns": {
          "headers": {"apns-priority": "10"},
          "payload": {
            "aps": {
              "alert": {"title": title, "body": body},
              "sound": "default",
            },
          },
        },
        "data": data ?? {},
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return "✅ Message sent successfully to device (with sound)!";
    } else {
      return "❌ Failed: ${response.statusCode} - ${response.body}";
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Send notification to multiple device tokens (multicast)
  // ---------------------------------------------------------------------------
  Future<String> sendToMultipleTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (tokens.isEmpty) {
      return "⚠️ No tokens provided.";
    }

    final accessToken = await _getAccessToken();
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    int successCount = 0;
    int failCount = 0;
    final List<String> failedTokens = [];

    // Send to each token concurrently
    final results = await Future.wait(tokens.map((token) async {
      final payload = {
        "message": {
          "token": token,
          "notification": {"title": title, "body": body},
          "android": {
            "priority": "HIGH",
            "notification": {
              "channel_id": "high_importance_channel",
              "sound": "default",
            },
          },
          "apns": {
            "headers": {"apns-priority": "10"},
            "payload": {
              "aps": {
                "alert": {"title": title, "body": body},
                "sound": "default",
              },
            },
          },
          "data": data ?? {},
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        successCount++;
        return "✅ Sent to $token";
      } else {
        failCount++;
        failedTokens.add(token);
        return "❌ $token -> ${response.statusCode}";
      }
    }));

    return "📦 Results:\n"
        "✅ Success: $successCount\n"
        "❌ Failed: $failCount\n"
        "🧾 Details:\n${results.join('\n')}";
  }
}
