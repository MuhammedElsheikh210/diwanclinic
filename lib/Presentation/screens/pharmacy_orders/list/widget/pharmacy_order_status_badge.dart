import '../../../../../index/index_main.dart';

class PharmacyOrderStatusBadge extends StatelessWidget {
  final String status;

  const PharmacyOrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late String label;

    switch (status) {
      case "pending":
        bg = AppColors.not_start;
        label = "قيد الانتظار";
        break;

      case "processing":
        bg = AppColors.tag_icon_warning;
        label = "جاري حساب السعر";
        break;

      // 🆕 calculated → الصيدلية حسبّت السعر
      case "calculated":
        bg = AppColors.blueForeground;
        label = "في انتظار الموافقة";
        break;

      // 🆕 confirmed → العميل وافق على السعر
      case "confirmed":
        bg = AppColors.primary;
        label = "تمت الموافقة من العميل";
        break;

      // الصيدلية بدأت التنفيذ
      case "approved":
        bg = AppColors.primary;
        label = "جاري التسعير";
        break;

      case "delivered":
        bg = AppColors.primary;
        label = "تم التوصيل";
        break;

      case "completed":
        bg = AppColors.blueForeground;
        label = "تم إرسال الطلب";
        break;

      case "cancelled":
        bg = AppColors.errorForeground;
        label = "ملغي";
        break;

      default:
        bg = AppColors.grayLight;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: label,
        textStyle: context.typography.xsMedium.copyWith(color: AppColors.white),
      ),
    );
  }
}
