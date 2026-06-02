import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class FcmSenderService {
  static const String _projectId = 'pos-app-c2ced';
  static const String _serviceAccountPath =
      'assets/config/pos-app-c2ced-11a26831ba47.json';
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  static Future<void> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(_serviceAccountPath);
      final credentials =
          ServiceAccountCredentials.fromJson(json.decode(jsonString));

      final client = await clientViaServiceAccount(credentials, _scopes);

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );

      final payload = {
        "message": {
          "token": token,
          "notification": {"title": title, "body": body},
          if (data != null) "data": data,
          "android": {"priority": "high"},
          "apns": {
            "headers": {"apns-priority": "10"},
          },
        }
      };

      await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      client.close();
    } catch (_) {}
  }
}
