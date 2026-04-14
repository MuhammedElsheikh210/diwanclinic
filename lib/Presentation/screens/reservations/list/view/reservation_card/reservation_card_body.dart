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
}
