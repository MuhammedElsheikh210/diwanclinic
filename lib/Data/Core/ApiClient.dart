import '../../index/index_main.dart';
import 'package:http/http.dart' as http;

enum HttpMethod {
  GET,
  POST,
  PATCH,
  PUT,
  DELETE;

  /// **Executes the HTTP Request based on the method**
  Future<http.Response> execute(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    switch (this) {
      case HttpMethod.GET:
        return await http.get(uri, headers: headers);
      case HttpMethod.POST:
        return await http.post(uri, headers: headers, body: body);
      case HttpMethod.PATCH:
        return await http.patch(uri, headers: headers, body: body);
      case HttpMethod.PUT:
        return await http.put(uri, headers: headers, body: body);
      case HttpMethod.DELETE:
        return await http.delete(uri, headers: headers);
    }
  }
}

class ClientSourceRepo {
  static const int timeoutDuration = 10; // Timeout duration in seconds
  static const String baseUrl =
      "https://pointofsales-aee83-default-rtdb.firebaseio.com";

  /// **Handles all Firebase API Requests**
  Future<dynamic> request(
    HttpMethod method,
    String path, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, method, param: params);
    headers ??= _getHeaders();

    try {
      // ✅ Remove null & empty values from params
      final cleanedParams = _cleanData(params);

      // ✅ Convert to JSON (for POST, PATCH, PUT)
      final requestBody =
          (method == HttpMethod.DELETE) ? null : jsonEncode(cleanedParams);

      final response = await method
          .execute(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: timeoutDuration));

      _debugRequest(uri, cleanedParams, response);
      // ✅ 1. Handle empty response `{}` or `""`
      if (response.body.isEmpty || response.body == "{}") {
        print("⚠️ Response is empty or `{}` → Returning empty list `[]`");
        return response.body;
      } else {
        return _handleResponse(response);
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// **Builds URI with `.json` format for Firebase**
  Uri _buildUri(String path, HttpMethod method, {Map<String, dynamic>? param}) {
    if (param == null) {
      return Uri.parse('${ApiConstatns.Base_Url}$path');
    } else {
      var queryString = param.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      return Uri.parse('${ApiConstatns.Base_Url}$path?$queryString');
    }
  }

  /// **Default Headers for Firebase Requests**
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// **Cleans Data by Removing Null/Empty Values**
  Map<String, dynamic> _cleanData(Map<String, dynamic>? data) {
    if (data == null) return {};
    return data
      ..removeWhere((key, value) => value == null || value.toString().isEmpty);
  }

  /// **Handles Firebase API Responses**
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ErrorHandler.handle(
        response,
        fromResponse: true,
        statusCode: response.statusCode,
      );
    }
  }

  /// **Debugging Helper for API Requests**
  void _debugRequest(
    Uri uri,
    Map<String, dynamic>? params,
    http.Response response,
  ) {
    print("🔗 **URL:** $uri");
    print("📡 **Method:** ${response.request?.method}");
    print("📜 **Headers:** ${response.request?.headers}");
    print("📝 **Params:** ${jsonEncode(params)}");
    print("📦 **Response Body:** ${response.body}");
    print("⚠️ **Status Code:** ${response.statusCode}");
  }
}
