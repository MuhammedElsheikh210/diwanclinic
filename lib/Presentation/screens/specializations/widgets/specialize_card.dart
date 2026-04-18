import 'package:diwanclinic/Presentation/screens/specializations/create_update/specialize_create.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../index/index_main.dart';

class SpecializeCard extends StatelessWidget {
  final CategoryEntity categoryEntity;
  final bool showAdminActions;

  const SpecializeCard({
    super.key,
    required this.categoryEntity,
    this.showAdminActions = false,
  });

  /// ✅ Return FontAwesome icon based on `icon_name` string
  IconData _getIconFromName(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      
      return FontAwesomeIcons.userDoctor;
    }

    switch (iconName) {
      // Existing
      case "stethoscope":
        return FontAwesomeIcons.stethoscope;
      case "heartPulse":
        return FontAwesomeIcons.heartPulse;
      case "brain":
        return FontAwesomeIcons.brain;
      case "bone":
        return FontAwesomeIcons.bone;
      case "spa":
        return FontAwesomeIcons.spa;
      case "tooth":
        return FontAwesomeIcons.tooth;
      case "baby":
        return FontAwesomeIcons.baby;
      case "earListen":
        return FontAwesomeIcons.earListen;
      case "venus":
        return FontAwesomeIcons.venus;
      case "eye":
        return FontAwesomeIcons.eye;
      case "personHalfDress":
      case "scalpelLineDashed":
        return FontAwesomeIcons.userDoctor;
      case "lungs":
        return FontAwesomeIcons.lungs;

      // Previously added
      case "heart":
        return FontAwesomeIcons.solidHeart;
      case "ear":
        return FontAwesomeIcons.earListen;
      case "gastro":
        return FontAwesomeIcons.bowlFood;
      case "ent":
        return FontAwesomeIcons.earListen;
      case "cardio":
        return FontAwesomeIcons.heartPulse;

      // NEW FIXED MAPPINGS
      case "pregnantWoman":
        return FontAwesomeIcons.personPregnant; // 👩‍🍼 Women health

      case "urology":
        return FontAwesomeIcons.kitMedical; // 🧬 Kidney / urinary icons

      case "skin":
        return FontAwesomeIcons.handDots; // 🖐️ Skin dermatology

      default:
        
        return FontAwesomeIcons.userDoctor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.background_black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🏥 Specialization Icon
          Container(
            height: 60.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIconFromName(categoryEntity.icon_name),
                color: AppColors.primary,
                size: 26.h,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // 🧠 Specialization Name
          Text(
            categoryEntity.name ?? "بدون اسم",
            textAlign: TextAlign.center,
            style: typography.mdBold.copyWith(
              color: AppColors.background_black,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // 👑 Admin Actions (optional)
          if (showAdminActions)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () {
                    showCustomBottomSheet(
                      context: context,
                      child: CreateSpecializeyView(
                        categoryEntity: categoryEntity,
                      ),
                    );
                  },
                  child: Svgicon(
                    icon: IconsConstants.edit_btn,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () => showConfirmBottomSheet(context),
                  child: Svgicon(
                    icon: IconsConstants.delete_btn,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 🗑️ Confirm Delete Dialog
  void showConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف التخصص؟",
          message: "لن تتمكن من استعادة البيانات بعد الحذف.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () {
         //   controller.deleteCategory(categoryEntity);
            Loader.showSuccess("تم حذف التخصص بنجاح");
          },
        );
      },
    );
  }
}
