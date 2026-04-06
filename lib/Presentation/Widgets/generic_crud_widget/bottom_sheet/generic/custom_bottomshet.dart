import '../../../../index/index_main.dart';

void showCustomBottomSheet({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  double heightFactor = 0.85, // 👈 تقدر تتحكم في الطول
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: true,
    // 🔥 أهم تعديل
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: heightFactor, // 👈 مش هتملى الشاشة
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
            bottom: 30.h,
            top: 20.h,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: child,
        ),
      );
    },
  );
}
