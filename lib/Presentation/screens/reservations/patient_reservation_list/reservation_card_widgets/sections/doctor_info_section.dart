import '../../../../../../../index/index_main.dart';

class DoctorInfoSection extends StatelessWidget {
  final ReservationModel reservation;

  const DoctorInfoSection({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ReservationListTileWidget(
              icon: IconsConstants.avatar,
              title: "الدكتور",
              body: reservation.doctorName ?? "غير معروف",
            ),
          ),
        ],
      ),
    );
  }
}
