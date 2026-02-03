import '../../index/index_main.dart';

class OnboardLocalCheck {
  bool? firstOpen;

  OnboardLocalCheck({this.firstOpen});

  factory OnboardLocalCheck.fromJson(Map<String, dynamic> json) {
    return OnboardLocalCheck(firstOpen: json['firstOpen']);
  }

  Map<String, dynamic> toJson() {
    return {'firstOpen': firstOpen};
  }
}

extension SaveLocalData on OnboardLocalCheck {
  Future<void> saveOnBoardLocal({Function? saveCallback}) async {
    final isSaved = await StorageService().setData(Strings.firstOepn, toJson());
    if (isSaved) {
      print("Saving data: ${toJson()}");
      saveCallback?.call();
    } else {
      Loader.showError("Not saved locally");
    }
  }

  OnboardLocalCheck? getOnBoardData() {
    final productJson = StorageService().getData(Strings.firstOepn);
    if (productJson != null) {
      try {
        print("Parsed data: $productJson"); // Debug log
        return OnboardLocalCheck.fromJson(productJson);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
}
