import 'dart:io';
import '../../../../../index/index_main.dart';

class PrescriptionUploadService {
  /// 🔹 Upload prescription image (handles 1st or 2nd slot)
  Future<void> upload({
    required ReservationModel reservation,
    required Function(ReservationModel updated) onUploaded,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (picked == null) return;

      Loader.show();

      final ref = FirebaseStorage.instance.ref().child(
        'prescriptions/${reservation.key}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      Loader.dismiss();
      Loader.showSuccess("تم رفع الصورة بنجاح");

      // 🔹 Place image in first empty slot
      if (reservation.prescriptionUrl1 == null ||
          reservation.prescriptionUrl1!.isEmpty) {
        reservation.prescriptionUrl1 = url;
      } else {
        reservation.prescriptionUrl2 = url;
      }

      // 🔥 Save to local + cloud
      await ReservationService().updateReservationData(
        reservation: reservation,
        voidCallBack: (_) {},
      );

      onUploaded(reservation);
    } catch (e) {
      Loader.dismiss();
      Loader.showError("فشل رفع صورة الروشتة");
    }
  }



  /// 🔹 Open bottom sheet for prescription images
  void openBottomSheet({
    required BuildContext context,
    required ReservationModel reservation,
    required VoidCallback onUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => PrescriptionBottomSheetWidget(
        reservation: reservation,
        onUpdated: onUpdated,
      ),
    );
  }
}
