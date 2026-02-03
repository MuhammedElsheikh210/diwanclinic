import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class PatientForAssistantProfileHistoryViewModel extends GetxController {
  PatientModel? patientModel;
  bool mustUploadForLastReservation = false;

  Map<String, List<FilesModel?>> reservationFilesMap =
      {}; // reservationKey -> files
  List<ReservationModel?> reservations = [];

  void getData(String patientKey) {
    PatientService().getPatientsData(
      data: {},
      query: SQLiteQueryParams(
        orderBy: 'create_at ${Strings.desc}',
        is_filtered: true,
        where: "key = ?",
        whereArgs: [patientKey],
      ),
      isFiltered: true,
      voidCallBack: (patients) {
        Loader.dismiss();
        if (patients.isNotEmpty) {
          patientModel = patients[0];

          ReservationService().getReservationsData(
            date: DateFormat('dd/MM/yyyy').format(DateTime.now()),

            data: FirebaseFilter(),
            query: SQLiteQueryParams(
              orderBy: 'create_at ${Strings.desc}', // ✅ get latest first
              is_filtered: true,
              where: "patient_key = ?",
              whereArgs: [patientKey],
            ),
            voidCallBack: (resList) {
              Loader.dismiss();

              reservations = resList;

              // reset flag
              mustUploadForLastReservation = false;

              if (reservations.isNotEmpty) {
                final lastRes = reservations.first; // because we ordered DESC
                if (lastRes?.key != null) {
                  FilesService().getFilesData(
                    data: {},
                    query: SQLiteQueryParams(
                      is_filtered: true,
                      where: "reservation_key = ?",
                      whereArgs: [lastRes!.key],
                    ),
                    isFiltered: true,
                    voidCallBack: (files) {
                      Loader.dismiss();
                      reservationFilesMap[lastRes.key!] = files;

                      // ✅ check if empty
                      if (files.isEmpty) {
                        mustUploadForLastReservation = true;
                      }

                      update();
                    },
                  );
                }
              }

              // fetch files for other reservations
              for (final res in reservations.skip(1)) {
                if (res?.key != null) {
                  FilesService().getFilesData(
                    data: {},
                    query: SQLiteQueryParams(
                      is_filtered: true,
                      where: "reservation_key = ?",
                      whereArgs: [res!.key],
                    ),
                    isFiltered: true,
                    voidCallBack: (files) {
                      Loader.dismiss();
                      reservationFilesMap[res.key!] = files;
                      update();
                    },
                  );
                }
              }

              update();
            },
          );
        }
      },
    );
  }

  updateReservation(ReservationModel reserv_model) {
    reserv_model.status = "completed";
    ReservationService().updateReservationData(
      date: reserv_model.appointmentDateTime ?? "",
      reservation: reserv_model,
      voidCallBack: (status) {
        Get.back();
        ReservationDoctorViewModel reservationDoctorViewModel = initController(
          () => ReservationDoctorViewModel(),
        );
        //  reservationDoctorViewModel.getReservationBannerData();
        Loader.showSuccess("تمت عملية الكشف بنجاح");
      },
    );
  }

  String calculateAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) return "-";
    try {
      final birth = DateFormat("dd/MM/yyyy").parse(birthday);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return "$age سنة";
    } catch (_) {
      return "-";
    }
  }
}
