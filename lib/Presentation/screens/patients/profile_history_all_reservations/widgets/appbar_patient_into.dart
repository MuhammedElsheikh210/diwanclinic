import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class PatientProfileHeaderCard extends StatelessWidget {
  final LocalUser? patient;

  final int reservationsCount;

  final ReservationModel? latestReservation;

  const PatientProfileHeaderCard({
    super.key,
    required this.patient,
    required this.reservationsCount,
    required this.latestReservation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),

      decoration: BoxDecoration(
        color: AppColors.white,

        borderRadius: BorderRadius.circular(26.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 20,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          /// Header
          _HeaderTopSection(patient: patient),

          SizedBox(height: 18.h),

          /// Divider
          Container(
            height: 1,

            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),

          SizedBox(height: 18.h),

          /// Stats
          Row(
            children: [
              Expanded(
                child: PatientStatCard(
                  title: "عدد الكشوفات",

                  value: reservationsCount.toString(),

                  icon: Icons.receipt_long_rounded,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: PatientStatCard(
                  title: "آخر زيارة",

                  value: _formatLastVisit(),

                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastVisit() {
    if (latestReservation == null) return "-";

    final createdAt = latestReservation?.createdAt;

    if (createdAt == null) return "-";

    return DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(createdAt));
  }
}

/// ----------------------------------------------------------------
/// Header Top Section
/// ----------------------------------------------------------------
class _HeaderTopSection extends StatelessWidget {
  final LocalUser? patient;

  const _HeaderTopSection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Avatar
        Container(
          width: 62.w,
          height: 62.h,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),

                AppColors.primary.withValues(alpha: 0.05),
              ],

              begin: Alignment.topLeft,

              end: Alignment.bottomRight,
            ),
          ),

          child: Icon(
            Icons.person_rounded,

            color: AppColors.primary,

            size: 32.sp,
          ),
        ),

        SizedBox(width: 14.w),

        /// Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                patient?.name ?? "-",

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: context.typography.xlBold.copyWith(
                  color: AppColors.background_black,
                ),
              ),

              SizedBox(height: 6.h),

              Row(
                children: [
                  Icon(
                    Icons.phone_rounded,

                    size: 16.sp,

                    color: AppColors.textSecondaryParagraph,
                  ),

                  SizedBox(width: 6.w),

                  Text(
                    patient?.phone ?? "-",

                    style: context.typography.smMedium.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// Back Button
        InkWell(
          borderRadius: BorderRadius.circular(16.r),

          onTap: () => Get.back(),

          child: Container(
            width: 48.w,
            height: 48.h,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),

              color: AppColors.background_neutral_100,
            ),

            child: Icon(
              Icons.arrow_forward_ios_rounded,

              size: 18.sp,

              color: AppColors.background_black,
            ),
          ),
        ),
      ],
    );
  }
}

/// ----------------------------------------------------------------
/// Stat Card
/// ----------------------------------------------------------------
class PatientStatCard extends StatelessWidget {
  final String title;

  final String value;

  final IconData icon;

  const PatientStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,

        borderRadius: BorderRadius.circular(20.r),

        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.6),
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 42.w,
            height: 42.h,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: AppColors.primary.withValues(alpha: 0.08),
            ),

            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),

          SizedBox(height: 12.h),

          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: context.typography.lgBold.copyWith(
              color: AppColors.background_black,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            title,

            textAlign: TextAlign.center,

            style: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
