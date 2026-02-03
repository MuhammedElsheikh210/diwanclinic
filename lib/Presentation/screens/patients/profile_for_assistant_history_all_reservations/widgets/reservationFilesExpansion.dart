import 'package:diwanclinic/Presentation/screens/patients/profile_for_assistant_history_all_reservations/patient_for_assistant_profile_history_view_model.dart';
import 'package:diwanclinic/Presentation/screens/patients/profile_for_assistant_history_all_reservations/widgets/file_card.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../../index/index_main.dart';

class ReservationForAssistantFilesExpansion extends StatelessWidget {
  final ReservationModel reservation;
  final List<FilesModel?> files;
  final bool initiallyExpanded;

  const ReservationForAssistantFilesExpansion({
    super.key,
    required this.reservation,
    required this.files,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      title: Text(
        "${reservation.appointmentDateTime ?? "-"} - ${reservation.reservationType ?? ""}",
        style: context.typography.mdMedium,
      ),
      children: [
        if (files.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("لا توجد ملفات لهذا الحجز"),
          ),
          UploadFilesWidget(reservationKey: reservation.key ?? "",patientKey: reservation.patientKey ?? "",),
        ] else ...[
          SizedBox(
            height: 220.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = files[index] ?? FilesModel();
                return FileAssistantCard(
                  file: file,
                  allFiles: files,
                  index: index,
                );
              },
            ),
          ),
          // 👇 Add more button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: UploadFilesWidget(
              reservationKey: reservation.key ?? "",
              patientKey: reservation.patientKey ?? "",
            ),
          ),
        ],
      ],
    );
  }
}

class UploadFilesWidget extends StatelessWidget {
  final String reservationKey;
  final String patientKey;

  const UploadFilesWidget({
    super.key,
    required this.reservationKey,
    required this.patientKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildUploadButton(context, "وصفة طبية", "prescription"),
        _buildUploadButton(context, "أشعة", "xray"),
        _buildUploadButton(context, "تحليل", "analysis"),
      ],
    );
  }

  Widget _buildUploadButton(BuildContext context, String label, String type) {
    return ElevatedButton.icon(
      onPressed: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (pickedFile == null) return;

        Loader.show();

        try {
          final file = File(pickedFile.path);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child("reservation_files")
              .child(reservationKey)
              .child("${const Uuid().v4()}.jpg");

          // Upload to Firebase
          await storageRef.putFile(file);

          // Get the URL
          final downloadUrl = await storageRef.getDownloadURL();

          // Save file data in DB
          final newFile = FilesModel(
            key: const Uuid().v4(),
            reservationKey: reservationKey,
            type: label,
            url: downloadUrl,
          );

          FilesService().addFileData(
            file: newFile,
            voidCallBack: (_) {
              Loader.dismiss();
              Loader.showSuccess("تم رفع $label بنجاح");

              // refresh reservations
              final vm = initController(
                () => PatientForAssistantProfileHistoryViewModel(),
              );
              vm.getData(patientKey); // 🔹 you may pass patientKey here
            },
          );
        } catch (e) {
          Loader.dismiss();
          Loader.showError("فشل رفع الملف: $e");
        }
      },
      icon: const Icon(Icons.upload_file),
      label: Text(label, style: context.typography.smRegular),
    );
  }
}
