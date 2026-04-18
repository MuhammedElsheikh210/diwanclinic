import 'package:diwanclinic/Global/Utils/logger.dart';

import '../../index/index_main.dart';
import 'package:http/http.dart' as http;

enum HttpMethod {
  GET,
  POST,
  PATCH,
  PUT,
  DELETE;

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
  static const int timeoutDuration = 10;
  static const String baseUrl =
      "https://pointofsales-aee83-default-rtdb.firebaseio.com";

  /// 🔥 Main Request Handler
  Future<dynamic> request(
      HttpMethod method,
      String path, {
        Map<String, dynamic>? params,
        Map<String, String>? headers,
      }) async {
    final uri = _buildUri(path, method, param: params);
    headers ??= _getHeaders();

    final cleanedParams = _cleanData(params);
    final stopwatch = AppLogger.startTimer();

    try {
      // 🟢 Log Request
      AppLogger.logRequest(
        url: uri.toString(),
        method: method.name,
        params: cleanedParams,
        headers: headers,
      );

      // ✅ Prepare Body
      final requestBody =
      (method == HttpMethod.GET || method == HttpMethod.DELETE)
          ? null
          : jsonEncode(cleanedParams);

      // 🚀 Execute Request
      final response = await method
          .execute(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: timeoutDuration));

      final duration = stopwatch.elapsed;

      // 🟢 Log Response
      AppLogger.logResponse(
        url: uri.toString(),
        statusCode: response.statusCode,
        body: response.body,
        duration: duration,
      );

      // ⚠️ Handle Empty Response
      if (response.body.isEmpty || response.body == "{}") {
        AppLogger.warning(
          "API_RESPONSE",
          "Empty response → returning empty result",
        );
        return response.body;
      }

      return _handleResponse(response);
    } catch (e, stackTrace) {
      // 🔴 Log Error
      AppLogger.logApiError(
        url: uri.toString(),
        error: e,
        stackTrace: stackTrace,
      );

      throw ErrorHandler.handle(e);
    }
  }

  /// 🔗 Build Firebase URL
  Uri _buildUri(String path, HttpMethod method,
      {Map<String, dynamic>? param}) {
    if (param == null || param.isEmpty) {
      return Uri.parse('${ApiConstatns.Base_Url}$path');
    } else {
      final queryString = param.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      return Uri.parse('${ApiConstatns.Base_Url}$path?$queryString');
    }
  }

  /// 📜 Default Headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 🧹 Clean Params
  Map<String, dynamic> _cleanData(Map<String, dynamic>? data) {
    if (data == null) return {};

    final cleaned = Map<String, dynamic>.from(data);
    cleaned.removeWhere(
            (key, value) => value == null || value.toString().isEmpty);

    return cleaned;
  }

  /// 📦 Handle Response
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
}