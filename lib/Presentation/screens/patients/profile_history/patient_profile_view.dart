import 'package:diwanclinic/Presentation/screens/patients/profile_history/widget/info_row.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class PatientProfileView extends StatefulWidget {
  final ReservationModel reservationModel;

  const PatientProfileView({super.key, required this.reservationModel});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  late final PatientProfileHistoryViewModel patientProfileHistoryViewModel;

  @override
  void initState() {
    patientProfileHistoryViewModel = initController(
      () => PatientProfileHistoryViewModel(),
    );
    patientProfileHistoryViewModel.getData(widget.reservationModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientProfileHistoryViewModel>(
      init: patientProfileHistoryViewModel,
      builder: (controller) {
        final patient = controller.patientModel;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text("الملف الشخصي", style: context.typography.lgBold),
          ),
          body:
              patient == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ✅ Patient Basic Info
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoRow(
                                label: "الاسم",
                                value: patient.name ?? "-",
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),

                              InfoRow(
                                label: "الهاتف",
                                value: patient.phone ?? "-",
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),

                              InfoRow(
                                label: "العنوان",
                                value: patient.address ?? "-",
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),

                              InfoRow(
                                label: "الكود",
                                value: patient.code ?? "-",
                              ),
                            ],
                          ),
                        ),
                      ),


                      // ✅ Reservation History Title
                      Text(
                        "سجل الملفات الطبية",
                        style: context.typography.mdBold.copyWith(
                          color: AppColors.text_primary_paragraph,
                        ),
                      ),

                      // ✅ Horizontal List of Files
                      (controller.list_files == null ||
                              controller.list_files!.isEmpty)
                          ? const Text("لا توجد ملفات لهذا الحجز")
                          : SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.list_files!.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final file =
                                    controller.list_files![index] ??
                                    FilesModel();
                                return FileCard(
                                  file: file,
                                  allFiles: controller.list_files ?? [],
                                  index: index,
                                );
                              },
                            ),
                          ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Get.context!.typography.smSemiBold),
        Text(value, style: Get.context!.typography.smRegular),
      ],
    );
  }
}
