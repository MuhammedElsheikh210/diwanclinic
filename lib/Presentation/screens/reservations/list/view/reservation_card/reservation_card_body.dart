import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_transfer_image.dart';

import '../../../../../../index/index_main.dart';

class ReservationCardBody extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationCardBody({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final transferImage = reservation.transferImage;

    return Row(
      children: [
        Padding(
          padding:
          const EdgeInsets.only(left: 12, right: 12, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info(context, "الإسم", reservation.patientName),
              _info(context, "الهاتف", reservation.patientPhone),
              _info(context, "المدفوع", reservation.paidAmount),
              if (reservation.patientCode?.isNotEmpty == true)
                _codeChip(context, reservation.patientCode!),
            ],
          ),
        ),
        if (transferImage != null && transferImage.isNotEmpty)
          ReservationCardTransferImage(imageUrl: transferImage),
      ],
    );
  }

  Widget _info(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        "$label : ${value ?? ""}",
        style: context.typography.lgBold.copyWith(
          color: AppColors.background_black,
        ),
      ),
    );
  }

  Widget _codeChip(BuildContext context, String code) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              "كود: $code",
              style: context.typography.smMedium
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
