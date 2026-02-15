import '../../../../../../index/index_main.dart';

class ReservationFilterManager {
  SQLiteQueryParams buildFilters({
    required ClinicModel? selectedClinic,
    required String? appointmentDate,
    required int selectedTab,
    bool isFiltered = true,
  }) {
    final conditions = <String>[];
    final whereArgs = <Object?>[];

    // Clinic filter
    if (selectedClinic?.key != null) {
      conditions.add("clinic_key = ?");
      whereArgs.add(selectedClinic!.key);
    }

    // Date filter
    if (appointmentDate != null) {
      conditions.add("appointment_date_time = ?");
      whereArgs.add(appointmentDate);
    }

    // Tab filter
    if (selectedTab == 1) {
      // مستعجل فقط
      conditions.add("reservation_type = ?");
      whereArgs.add("كشف مستعجل");
    } else if (selectedTab == 0) {
      // كل شيء ما عدا المستعجل
      conditions.add("reservation_type != ?");
      whereArgs.add("كشف مستعجل");
    }

    final where = conditions.isNotEmpty ? conditions.join(" AND ") : null;
    return SQLiteQueryParams(
      is_filtered: isFiltered,
      where: where,
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
