class ErrorsModelSignUp {
  final Map<String, List<String>> errors;

  ErrorsModelSignUp({required this.errors});

  /// Factory constructor to create an instance from JSON
  factory ErrorsModelSignUp.fromJson(Map<String, dynamic> json) {
    return ErrorsModelSignUp(
      errors: (json['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  /// Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map(
        (key, value) => MapEntry(key, value),
      ),
    };
  }

  /// Override toString to provide a readable string representation
  @override
  String toString() {
    return errors.entries
        .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
        .join("\n");
  }
}
