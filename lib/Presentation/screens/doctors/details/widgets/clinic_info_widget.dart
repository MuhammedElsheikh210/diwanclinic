import '../../../../../../index/index_main.dart';

class ClinicInfoWidget extends StatelessWidget {
  final ClinicModel clinic;
  final String? selectedReservationType;

  const ClinicInfoWidget({
    super.key,
    required this.clinic,
    this.selectedReservationType,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // 🏥 Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                clinic.title ?? "عيادة غير معروفة",
                style: typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        _divider(),

        // 📅 Info Rows
        if (clinic.dailyWorks?.isNotEmpty == true)
          _infoRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: "أيام العمل",
            value: clinic.dailyWorks!,
          ),

        if (clinic.address?.isNotEmpty == true)
          _infoRow(
            context,
            icon: Icons.location_on_rounded,
            label: "العنوان",
            value: clinic.address!,
          ),

        if (clinic.phone1?.isNotEmpty == true)
          _infoRow(
            context,
            icon: Icons.phone_in_talk_rounded,
            label: "التليفون",
            value:
                "${clinic.phone1 ?? ''}${clinic.phone2 != null ? ' - ${clinic.phone2}' : ''}",
          ),

        SizedBox(height: 12.h),
        _divider(),

        // 💰 Prices Section
        Text(
          "أسعار الكشف",
          style: typography.lgBold.copyWith(color: AppColors.textDisplay),
        ),
        SizedBox(height: 8.h),

        _priceRow(
          context,
          title: "الكشف العادي",
          amount: clinic.consultationPrice,
          icon: Icons.event_available_rounded,
        ),
        _priceRow(
          context,
          title: "الكشف المستعجل",
          amount: clinic.urgentConsultationPrice,
          icon: Icons.flash_on_rounded,
          iconColor: AppColors.errorForeground,
        ),
        _priceRow(
          context,
          title: "الإعادة",
          amount: clinic.followUpPrice,
          icon: Icons.refresh_rounded,
          iconColor: AppColors.textSecondaryParagraph,
        ),
      ],
    );
  }

  // 🔹 Divider
  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Container(
      height: 1,
      color: AppColors.borderNeutralPrimary.withOpacity(0.25),
    ),
  );

  // 🔹 Info Row
  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary60, size: 20),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: typography.smMedium.copyWith(
                  color: AppColors.textDisplay,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: typography.mdMedium.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  TextSpan(text: value, style: typography.mdMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Price Row
  Widget _priceRow(
    BuildContext context, {
    required String title,
    required String? amount,
    required IconData icon,
    Color? iconColor,
  }) {
    if (amount == null || amount.isEmpty) return const SizedBox();
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary60, size: 20),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: typography.mdMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          Text(
            "$amount ج.م",
            style: typography.lgBold.copyWith(color: AppColors.textDisplay),
          ),
        ],
      ),
    );
  }
}
