import '../../../../../index/index_main.dart';
import 'patient_info_row.dart';
import 'section_header.dart';

class PatientInfoCard extends StatelessWidget {
  final LocalUser? patient;

  const PatientInfoCard({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderNeutralPrimary,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.person_outline,
            title: "بيانات الحالة",
          ),

          const SizedBox(height: 16),

          PatientInfoRow(
            icon: Icons.badge_outlined,
            label: "الاسم",
            value: patient?.name ?? "-",
          ),

          PatientInfoRow(
            icon: Icons.phone,
            label: "الهاتف",
            value: patient?.phone ?? "-",
          ),
        ],
      ),
    );
  }
}