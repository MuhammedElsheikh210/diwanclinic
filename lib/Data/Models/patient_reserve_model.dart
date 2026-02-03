class ReservationMetaModel {
  final String? key;
  final String? date; // مثال: "03-12-2025" or "03/12/2025"
  final String? doctorUid; // UID الخاص بالطبيب
  final String? reservationType; // كشف جديد / متابعة / مستعجل...

  ReservationMetaModel({
    this.key,
    this.date,
    this.doctorUid,
    this.reservationType,
  });

  // ------------------------------------------------------------
  // 🔹 fromJson
  // ------------------------------------------------------------
  factory ReservationMetaModel.fromJson(Map<String, dynamic> json) {
    return ReservationMetaModel(
      key: json["key"],
      date: json["date"],
      doctorUid: json["doctor_uid"],
      reservationType: json["reservation_type"],
    );
  }

  // ------------------------------------------------------------
  // 🔹 toJson
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      if (key != null) "key": key,
      if (date != null) "date": date,
      if (doctorUid != null) "doctor_uid": doctorUid,
      if (reservationType != null) "reservation_type": reservationType,
    };
  }

  // ------------------------------------------------------------
  // 🔹 copyWith
  // ------------------------------------------------------------
  ReservationMetaModel copyWith({
    String? key,
    String? date,
    String? doctorUid,
    String? reservationType,
  }) {
    return ReservationMetaModel(
      key: key ?? this.key,
      date: date ?? this.date,
      doctorUid: doctorUid ?? this.doctorUid,
      reservationType: reservationType ?? this.reservationType,
    );
  }

  @override
  String toString() {
    return "ReservationMetaModel(key: $key, date: $date, doctorUid: $doctorUid, reservationType: $reservationType)";
  }
}
