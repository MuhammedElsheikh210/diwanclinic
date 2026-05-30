import '../../../../../index/index_main.dart';

/// Displays one pharmacy (primary account) with its staff list.
class PharmacyCard extends StatelessWidget {
  final LocalUser? pharmacy; // primary account
  final List<LocalUser> staffList; // all accounts (including primary)
  final PharmacyViewModel controller;

  const PharmacyCard({
    Key? key,
    required this.pharmacy,
    required this.staffList,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pharmacyId = pharmacy?.pharmacyId ?? pharmacy?.uid ?? '';
    final extraStaff = staffList.where((s) => s.uid != pharmacy?.uid).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Primary pharmacy row ─────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            child: Row(
              children: [
                const Icon(Icons.local_pharmacy_outlined,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    pharmacy?.name ?? "",
                    style: context.typography.lgBold.copyWith(
                      color: AppColors.background_black,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Add staff button
                InkWell(
                  onTap: () {
                    Get.delete<CreatePharmacyViewModel>();
                    showCustomBottomSheet(
                      context: context,
                      child: CreatePharmacyView(
                        parentPharmacyId: pharmacyId,
                      ),
                    );
                  },
                  child: Tooltip(
                    message: "إضافة موظف",
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_outlined,
                              color: AppColors.primary, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            "موظف",
                            style: context.typography.smMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Edit Button
                InkWell(
                  onTap: () {
                    Get.delete<CreatePharmacyViewModel>();
                    showCustomBottomSheet(
                      context: context,
                      child: CreatePharmacyView(pharmacy: pharmacy),
                    );
                  },
                  child: Svgicon(
                    icon: IconsConstants.edit_btn,
                    height: 28.h,
                    width: 28.w,
                  ),
                ),
                SizedBox(width: 6.w),
                // Delete Button
                InkWell(
                  onTap: () => _showConfirmBottomSheet(context),
                  child: Svgicon(
                    icon: IconsConstants.delete_btn,
                    height: 28.h,
                    width: 28.w,
                  ),
                ),
              ],
            ),
          ),

          // ── Staff list (exclude primary) ────────────────────
          if (extraStaff.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.borderNeutralPrimary),
            ...extraStaff.map(
              (staff) => _StaffRow(
                staff: staff,
                controller: controller,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف الصيدلية؟",
          message: "سيتم حذف هذا الحساب. الموظفين الآخرين لن يتأثروا.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () {
            controller.deletePharmacy(pharmacy);
            Loader.showSuccess("تم حذف الحساب بنجاح");
          },
        );
      },
    );
  }
}

class _StaffRow extends StatelessWidget {
  final LocalUser staff;
  final PharmacyViewModel controller;

  const _StaffRow({required this.staff, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18,
              color: AppColors.textSecondaryParagraph),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name ?? "",
                  style: context.typography.smMedium,
                ),
                if (staff.phone != null)
                  Text(
                    staff.phone!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.delete<CreatePharmacyViewModel>();
              showCustomBottomSheet(
                context: context,
                child: CreatePharmacyView(pharmacy: staff),
              );
            },
            child: Svgicon(
              icon: IconsConstants.edit_btn,
              height: 24.h,
              width: 24.w,
            ),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () => _showDeleteStaff(context),
            child: Svgicon(
              icon: IconsConstants.delete_btn,
              height: 24.h,
              width: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteStaff(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ConfirmBottomSheet(
          title: "حذف الموظف؟",
          message: "سيتم حذف حساب ${staff.name ?? 'هذا الموظف'}.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () {
            controller.deletePharmacy(staff);
            Loader.showSuccess("تم حذف الموظف بنجاح");
          },
        );
      },
    );
  }
}
