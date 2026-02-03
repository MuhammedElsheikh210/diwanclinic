// 🔹 Enum for User Types
enum UserType { admin, sales, doctor, assistant, pharmacy, patient }

extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.admin:
        return "admin";
      case UserType.patient:
        return "patient";
      case UserType.sales:
        return "sales";
      case UserType.doctor:
        return "doctor";
      case UserType.assistant:
        return "assistant";
      case UserType.pharmacy:
        return "pharmacy";
    }
  }

  static UserType? fromString(String? value) {
    if (value == null) return null;
    return UserType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserType.admin, // default fallback
    );
  }
}
