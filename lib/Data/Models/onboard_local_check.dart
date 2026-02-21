import '../../index/index_main.dart';

class OnboardLocalCheck {
  final bool hasSeenOnboard;

  OnboardLocalCheck({required this.hasSeenOnboard});

  factory OnboardLocalCheck.fromJson(Map<String, dynamic> json) {
    return OnboardLocalCheck(
      hasSeenOnboard: json['hasSeenOnboard'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasSeenOnboard': hasSeenOnboard,
    };
  }

  /// 🔹 Save onboard locally
  Future<void> save() async {
    await StorageService().setData(
      Strings.hasSeenOnboard, // غير الاسم ده لو عندك مختلف
      toJson(),
    );
  }

  /// 🔹 Check if onboard already seen
  static bool isOnboardSeen() {
    final data = StorageService().getData(Strings.hasSeenOnboard);

    if (data == null) return false;

    try {
      final model = OnboardLocalCheck.fromJson(data);
      return model.hasSeenOnboard;
    } catch (_) {
      return false;
    }
  }

  /// 🔹 Clear onboard (optional – useful for logout)
  static Future<void> clear() async {
    await StorageService().remove(Strings.hasSeenOnboard);
  }
}
