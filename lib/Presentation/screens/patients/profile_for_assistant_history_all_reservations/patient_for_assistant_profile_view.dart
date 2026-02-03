import 'package:diwanclinic/Presentation/screens/patients/profile_for_assistant_history_all_reservations/patient_for_assistant_profile_history_view_model.dart';
import 'package:diwanclinic/Presentation/screens/patients/profile_for_assistant_history_all_reservations/widgets/reservationFilesExpansion.dart';

import '../../../../index/index_main.dart';

class PatientForAssistantProfileView extends StatefulWidget {
  final ReservationModel reservationModel;

  const PatientForAssistantProfileView({
    super.key,
    required this.reservationModel,
  });

  @override
  State<PatientForAssistantProfileView> createState() =>
      _PatientForAssistantProfileViewState();
}

class _PatientForAssistantProfileViewState
    extends State<PatientForAssistantProfileView> {
  late final PatientForAssistantProfileHistoryViewModel controller;

  @override
  void initState() {
    controller = initController(
      () => PatientForAssistantProfileHistoryViewModel(),
    );
    controller.getData(widget.reservationModel.patientKey ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientForAssistantProfileHistoryViewModel>(
      init: controller,
      builder: (vm) {
        final patient = vm.patientModel;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text("الملف الشخصي", style: context.typography.lgBold),
          ),

          body: patient == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  children: [
                    if (vm.mustUploadForLastReservation)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "⚠️ يجب رفع ملفات (وصفة / أشعة / تحليل) للحجز الأخير",
                          style: context.typography.mdBold.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),

                    // ✅ Patient Info
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            InfoRowWidget(
                              label: "الاسم",
                              value: patient.name ?? "-",
                            ),
                            InfoRowWidget(
                              label: "الهاتف",
                              value: patient.phone ?? "-",
                            ),
                            InfoRowWidget(
                              label: "العنوان",
                              value: patient.address ?? "-",
                            ),
                            InfoRowWidget(
                              label: "العمر",
                              value: patient.birthday ?? "",
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ✅ Reservation history expandable list
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                      child: Text(
                        "سجل الحجوزات",
                        style: context.typography.lgBold.copyWith(
                          color: AppColors.text_primary_paragraph,
                        ),
                      ),
                    ),

                    ...(vm.reservations).asMap().entries.map((entry) {
                      final index = entry.key;
                      final res = entry.value;
                      final files =
                          vm.reservationFilesMap[res?.key ?? ""] ?? [];

                      return ReservationForAssistantFilesExpansion(
                        reservation: res ?? ReservationModel(),
                        files: files,
                        initiallyExpanded: index == 0, // ✅ first one expanded
                      );
                    }).toList(),
                  ],
                ),
        );
      },
    );
  }
}
