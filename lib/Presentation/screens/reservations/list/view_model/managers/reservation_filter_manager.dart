import '../../../../../../index/index_main.dart';

class ReservationFilterManager {

  // Build SQLite query filters based on clinic, date, and selected tab
  SQLiteQueryParams buildFilters({
    required ClinicModel? selectedClinic,
    required String? appointmentDate,
    required int selectedTab,
    bool isFiltered = true,
  }) {
    String where = "";
    List<Object?> whereArgs = [];

    if (selectedClinic?.key != null) {
      where = "clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    if (appointmentDate != null) {
      if (where.isEmpty) {
        where = "appointment_date_time = ?";
      } else {
        where += " AND appointment_date_time = ?";
      }
      whereArgs.add(appointmentDate);
    }

    if (selectedTab == 1) {
      if (where.isEmpty) {
        where = "reservation_type = ?";
      } else {
        where += " AND reservation_type = ?";
      }
      whereArgs.add("كشف مستعجل");
    }

    if (selectedTab == 0) {
      if (where.isEmpty) {
        where = "reservation_type != ?";
      } else {
        where += " AND reservation_type != ?";
      }
      whereArgs.add("كشف مستعجل");
    }

    return SQLiteQueryParams(
      is_filtered: isFiltered,
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: """
        CASE status 
          WHEN 'in_progress' THEN 1
          WHEN 'pending' THEN 2
          WHEN 'approved' THEN 3
          ELSE 4
        END,
        order_num ASC
      """,
    );
  }
}
