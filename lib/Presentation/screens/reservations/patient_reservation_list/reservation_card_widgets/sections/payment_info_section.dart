import '../../../../../../../index/index_main.dart';

class PaymentInfoSection extends StatelessWidget {
  final ReservationModel reservation;

  const PaymentInfoSection({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ReservationListTileWidget(
              icon: IconsConstants.money,
              title: "المدفوع",
              body: "${reservation.paidAmount ?? '0'} جنيه",
            ),
          ),
          Expanded(
            child: ReservationListTileWidget(
              icon: IconsConstants.money,
              title: "المتبقي",
              body: "${reservation.restAmount ?? '0'} جنيه",
            ),
          ),
        ],
      ),
    );
  }
}
