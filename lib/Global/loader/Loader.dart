import '../../index/index_main.dart';

class Loader {
  static show() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 3000)
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 100
      ..radius = 10
      ..lineWidth = 10
      ..maskColor = Colors.grey
      ..indicatorColor = ColorResources.COLOR_Primary
      ..userInteractions = false
      ..dismissOnTap = true
      ..backgroundColor = Colors.transparent
      ..textColor = ColorResources.COLOR_Primary
      ..boxShadow = <BoxShadow>[]
      ..indicatorType = EasyLoadingIndicatorType.chasingDots;
    EasyLoading.show(status: '');
  }

  static dismiss() {
    EasyLoading.dismiss();
  }

  /// **Show Information Message (Uses Overlay like Error)**
  static showInfo(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedInfoMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  /// **Show Success Message (Uses Overlay like Error)**
  static showSuccess(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedSuccessMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  /// **Show Error Message (Already Uses Overlay)**
  static void showError(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedErrorMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }
}
