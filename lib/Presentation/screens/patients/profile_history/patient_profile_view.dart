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
          body: patient == null
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
                            _infoRow("الاسم", patient.name ?? "-"),
                            const Divider(),
                            _infoRow("الهاتف", patient.phone ?? "-"),
                            const Divider(),
                            _infoRow("العنوان", patient.address ?? "-"),
                            const Divider(),
                            _infoRow("الكود", patient.code ?? "-"),

                            // _infoRow("العمر", _calculateAge(patient.birthday)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Reservation History Title
                    Text(
                      "سجل الملفات الطبية",
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Horizontal List of Files
                    (controller.list_files == null ||
                            controller.list_files!.isEmpty)
                        ? const Text("لا توجد ملفات لهذا الحجز")
                        : SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.list_files!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final file =
                                    controller.list_files![index] ??
                                    FilesModel();
                                return _fileCard(
                                  file,
                                  context,
                                  controller.list_files!,
                                  index,
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

  /// ✅ File Card Widget
  Widget _fileCard(
    FilesModel file,
    BuildContext context,
    List<FilesModel?> allFiles,
    int index,
  ) {
    return InkWell(
      onTap: () {
        final imageUrls = allFiles
            .where((f) => f?.url != null && f!.url!.isNotEmpty)
            .map((f) => f!.url!)
            .toList();

        final initialIndex = imageUrls.indexOf(file.url ?? "");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              imageUrls: imageUrls,
              initialIndex: initialIndex >= 0 ? initialIndex : 0,
              title: file.type ?? "ملف طبي",
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: file.url != null && file.url!.isNotEmpty
                    ? Image.network(
                        file.url!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.insert_drive_file,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                file.type ?? "ملف",
                style: context.typography.mdMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) return "-";
    try {
      final birthDate = DateFormat("dd/MM/yyyy").parse(birthday);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return "$age سنة";
    } catch (_) {
      return "-";
    }
  }
}
