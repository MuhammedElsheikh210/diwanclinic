import '../../../../index/index_main.dart';

/// ✅ **Generic Bottom Sheet Launcher**
void showCustomBottomSheet({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    elevation: 1,

    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding:  EdgeInsets.only(
          left: 15.w,
          right: 15.w,
          bottom: 30.h,
          top: 30.h,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: child, // 🔥 Pass any widget here!
      );
    },
  );
}
