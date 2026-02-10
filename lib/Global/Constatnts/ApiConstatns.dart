// ignore_for_file: constant_identifier_names

import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import '../../index/index_main.dart';

class ApiConstatns {
  ApiConstatns._();

  static const Map<String, String> header = {
    "Content-Type": "application/json",
  };

  static const String Base_Url =
      "https://pos-app-c2ced-default-rtdb.firebaseio.com";

  // ---------- Dynamic UID ----------
  static String? get uid {
    final user = LocalUser().getUserData();

    if (user.userType?.name == Strings.doctor) {
      return user.uid;
    } else {
      return user.doctorKey;
    }
  }

  // ---------- API Endpoints ----------
  static String get register => "doctors/$uid/register";

  static String get login => "doctors/$uid/auth/login";

  static String get clients => "clients";

  static String get orders => "orders";

  static String get transactions => "transactions";

  static String get organization => "sync";

  static String get doctors => "doctors";

  static String get patients => "patients";

  static String get notifications => "notifications";

  static String get assistants => "assistants";

  static String get clinics => "doctors/$uid/clinics";

  static String get clinics_patient => "doctors/";

  // ❌ OLD — REMOVE THIS
  // static String get reservations => "doctors/$uid/reservations";

  // ✅ NEW — reservations grouped by date
  static String reservationsByDate(String date) {
    final safeDate = date.replaceAll("/", "-").trim();
    return "doctors/$uid/reservations/$safeDate";
  }

  // sync reservations
  static String get syncNodel => "doctors/$uid/SyncReservations/";

  static String get files => "files";

  static String get transfers => "transfers";

  static String get expenses => "expense";

  static String get specializations => "specializations";

  static String get shifts => "doctors/$uid/shifts";

  static String get shiftsFromPatient => "doctors/";

  static String get doctor_reviews => "doctors/$uid/doctor_reviews";

  static String get archivePatients => "doctors/$uid/archivePatients";

  static String get legacy_reservations => "doctors/$uid/legacy_queue";

  static String get archiveForms => "doctors/$uid/archiveForms";

  static String get doctor_reviews_patient => "doctors/";

  static String get income_model => "incomes";

  static String get visits => "visits";

  static String get doctorSuggestions => "doctorSuggestions";
}
