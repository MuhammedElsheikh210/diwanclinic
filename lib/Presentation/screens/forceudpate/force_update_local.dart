import '../../../index/index_main.dart';

class ForceUdpate {
  bool? forceUpdate; // Fixed typo in property name

  ForceUdpate({
    this.forceUpdate,
  });

  factory ForceUdpate.fromJson(Map<String, dynamic> json) {
    return ForceUdpate(
      forceUpdate: json['forceUpdate'], // Fixed JSON key mapping
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forceUpdate': forceUpdate, // Fixed JSON key for consistency
    };
  }
}

extension SaveLocalData on ForceUdpate {
  Future<void> saveOnBoardLocal({Function? saveCallback}) async {
    final isSaved = await StorageService().setData("forceUpdate", toJson());
    if (isSaved) {
      saveCallback?.call();
    } else {
      Loader.showError("Not saved locally");
    }
  }

  ForceUdpate? getForceUpdateData() {
    final productJson = StorageService().getData("forceUpdate");
    if (productJson != null) {
      try {
        return ForceUdpate.fromJson(productJson);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
}
