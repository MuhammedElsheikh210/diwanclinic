import '../../../../index/index_main.dart';

Widget buildTimeline(
  CreateReservationViewModel controller,
  BuildContext context,
) {
  if (controller.patientReservations.isEmpty) {
    return const SizedBox();
  }

  final list = controller.patientReservations;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        /// HEADER
        GestureDetector(
          onTap: controller.toggleTimeline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.primary.withOpacity(0.06),
            ),
            child: Row(
              children: [
                const Icon(Icons.timeline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "سجل زيارات المريض",
                    style: context.typography.mdBold,
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: controller.isTimelineExpanded ? 0.5 : 0,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),

        if (controller.isTimelineExpanded)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _modernTimelineItem(
                item: list[index],
                isLast: index == list.length - 1,
                context: context,
              );
            },
          ),
      ],
    ),
  );
}

Widget _modernTimelineItem({
  required ReservationModel? item,
  required bool isLast,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 TIMELINE (centered fixed width)
        SizedBox(
          width: 28, // 🔥 السر هنا
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),

              /// dotted line
              if (!isLast)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: List.generate(
                      6,
                      (_) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 1,
                        height: 6,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        /// 🔥 CARD
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TYPE + AMOUNT
                Row(
                  children: [
                    _modernIcon(item?.reservationType),

                    const SizedBox(width: 10),

                    Text(
                      item?.reservationType ?? "",
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "${item?.paidAmount} ج.م",
                      style: context.typography.mdBold.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// DATE
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item?.appointmentDateTime ?? "",
                      style: context.typography.smRegular.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _modernIcon(String? type) {
  switch (type) {
    case "كشف جديد":
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, size: 16, color: Colors.blue),
      );

    case "إعادة":
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.refresh, size: 16, color: Colors.orange),
      );

    default:
      return const SizedBox();
  }
}
