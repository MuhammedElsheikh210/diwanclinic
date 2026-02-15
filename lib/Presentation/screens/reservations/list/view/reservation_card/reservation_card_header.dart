import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_queue_section.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_status_section.dart';

import '../../../../../../index/index_main.dart';

class ReservationCardHeader extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;
  final ReservationNewStatus status;
  final int ahead;
  final bool isCompletedOrCancelled;

  const ReservationCardHeader({
    super.key,
    required this.reservation,
    required this.controller,
    required this.status,
    required this.ahead,
    required this.isCompletedOrCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final bool showQueueSection =
        !isCompletedOrCancelled && reservation.reservationType != "كشف مستعجل";

    return Container(
      decoration: BoxDecoration(
        color: ColorMappingImpl().background_neutral_100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          if (showQueueSection)
            Expanded(
              child: ReservationCardQueueSection(
                reservation: reservation,
                ahead: ahead,
                status: status,
              ),
            ),

          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ReservationCardStatusSection(
                reservation: reservation,
                status: status,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
