
class ApiErrorModel {
  final String message;
  final int? code;

  ApiErrorModel({
    required this.message,
    this.code,
  });

  /// Factory method to handle dynamic response and return an appropriate ApiErrorModel
  factory ApiErrorModel.fromDynamic(dynamic response, {int? statusCode}) {
    print("response innn api is $response");
    if (response is String) {
      // If response is a plain string, directly assign it to the message
      return ApiErrorModel(message: response, code: statusCode);
    } else if (response is Map<String, dynamic>) {
      // If response is a map, decode it and check for errors or message
      if (response.containsKey('message') && response['message'] is String) {
        // If the map contains a `message` field
        return ApiErrorModel(
          message: response['message'],
          code: statusCode,
        );
      } else if (response.containsKey('errors')) {
        // If the map contains an `errors` field
        final errors = response['errors'];

        if (errors is String) {
          // If errors is a plain string
          return ApiErrorModel(
            message: errors,
            code: statusCode,
          );
        } else if (errors is Map<String, dynamic>) {

          // If errors is a map, convert it to a readable string
          final buffer = StringBuffer();
          errors.forEach((key, value) {
            buffer.writeln('${value.join(', ')}');
          });
          return ApiErrorModel(
            message: buffer.toString(),
            code: statusCode,
          );
        }
      }
    }

    // Default fallback for unexpected response structure
    return ApiErrorModel(
      message: "Unexpected response format",
      code: statusCode,
    );
  }

  @override
  String toString() {
    return message;
  }
}
