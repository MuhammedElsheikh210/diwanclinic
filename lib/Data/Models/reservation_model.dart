class ReservationModel {
  final String? key;

  /// 🕒 timestamps
  final int? createdAt;
  int? updatedAt;
  int? serverUpdatedAt;

  /// 🏥 relations
  final String? clinicKey;
  final String? shiftKey;
  String? medicalCenterKey;

  /// 👨‍⚕️ doctor
  final String? doctorUid;
  final String? doctorName;
  final String? doctorFcm;

  /// 🧑‍⚕️ assistant
  String? assistantUid;
  final String? assistantName;
  final String? assistantFcm;

  /// 👤 patient
  final String? patientUid;
  final String? patientName;
  final String? patientPhone;
  final String? patientFcm;
  final String? patientCode;

  final int? revisitCount;
  final String? parentKey;
  final bool? isAutoType;

  /// 📅 reservation
  final String? appointmentDateTime;
  String? status;
  final String? reservationType;

  /// 💰 financial
  final String? paidAmount;
  final String? restAmount;
  final String? totalFees;

  /// 🔢 order
  int? orderNum;
  int? orderReserved;

  /// 🧠 Smart Queue Fields
  int? priorityLevel;      // 0=normal 1=vip 2=elderly 3=newborn 4=urgent
  int? checkedInAt;        // timestamp when patient first checked in at clinic
  int? missedReturnedAt;   // timestamp when patient returned after being missed
  String? queueReason;     // last reason queue position changed (QueueChangeReason.systemLabel)

  /// 🧾 medical
  final String? allergies;
  final String? diagnosis;
  final String? temperature;
  final String? weight;
  final String? height;

  /// 📎 attachments
  final String? transferImage;

  String? prescriptionUrl1;
  String? prescriptionUrl2;
  String? prescriptionUrl3;
  String? prescriptionUrl4;
  String? prescriptionUrl5;

  /// 💳 online payment
  String? paymentScreenshotUrl;
  String? paymentMethod;   // 'wallet' | 'instapay' | 'cash'
  String? paymentStatus;   // 'pending_payment' | 'payment_approved' | 'payment_rejected'

  /// 🗺️ clinic location (denormalized at create time)
  String? clinicAddress;
  double? clinicLatitude;
  double? clinicLongitude;

  /// ⚙️ flags
  bool isOrdered;
  bool hasFeedback;
  bool isDeleted;

  ReservationModel({
    this.key,
    this.createdAt,
    this.updatedAt,
    this.serverUpdatedAt,

    this.clinicKey,
    this.shiftKey,
    this.medicalCenterKey,

    this.doctorUid,
    this.doctorName,
    this.doctorFcm,

    this.revisitCount,
    this.parentKey,
    this.isAutoType,

    this.assistantUid,
    this.assistantName,
    this.assistantFcm,

    this.patientUid,
    this.patientName,
    this.patientPhone,
    this.patientFcm,
    this.patientCode,

    this.appointmentDateTime,
    this.status,
    this.reservationType,

    this.paidAmount,
    this.restAmount,
    this.totalFees,

    this.orderNum,
    this.orderReserved,
    this.priorityLevel,
    this.checkedInAt,
    this.missedReturnedAt,
    this.queueReason,

    this.allergies,
    this.diagnosis,
    this.temperature,
    this.weight,
    this.height,

    this.transferImage,

    this.prescriptionUrl1,
    this.prescriptionUrl2,
    this.prescriptionUrl3,
    this.prescriptionUrl4,
    this.prescriptionUrl5,

    this.paymentScreenshotUrl,
    this.paymentMethod,
    this.paymentStatus,

    this.clinicAddress,
    this.clinicLatitude,
    this.clinicLongitude,

    this.isOrdered = false,
    this.hasFeedback = false,
    this.isDeleted = false,
  });

  bool get isCheckedIn         => checkedInAt != null;
  bool get isHardPriority      => (priorityLevel ?? 0) >= 3;
  bool get hasSoftPriority     => (priorityLevel ?? 0) >= 1;
  bool get isReturnedFromMissed => missedReturnedAt != null;

  /// وقت الوصول الفعلي:
  /// لو المريض رجع بعد missed → missedReturnedAt
  /// غير ذلك → checkedInAt
  int? get effectiveArrivalTime => missedReturnedAt ?? checkedInAt;

  // Helper
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    /// 🕒 timestamps
    put('created_at', createdAt);
    put('updated_at', updatedAt);
    put('server_updated_at', serverUpdatedAt);
    data['is_deleted'] = isDeleted ? 1 : 0;

    /// 🔑 key
    put('key', key);

    /// 🏥 relations
    put('clinic_key', clinicKey);
    put('shift_key', shiftKey);
    put('medical_center_key', medicalCenterKey);

    /// 👨‍⚕️ doctor
    put('doctor_uid', doctorUid);
    put('doctor_name', doctorName);
    put('doctor_fcm', doctorFcm);

    put('revisit_count', revisitCount);
    put('parent_key', parentKey);
    data['is_auto_type'] = (isAutoType ?? false) ? 1 : 0;

    /// 🧑‍⚕️ assistant
    put('assistant_uid', assistantUid);
    put('assistant_name', assistantName);
    put('assistant_fcm', assistantFcm);

    /// 👤 patient
    put('patient_uid', patientUid);
    put('patient_name', patientName);
    put('patient_phone', patientPhone);
    put('patient_fcm', patientFcm);
    put('patient_code', patientCode);

    /// 📅 reservation
    put('appointment_date_time', appointmentDateTime);
    put('status', status);
    put('reservation_type', reservationType);

    /// 💰 financial
    put('paid_amount', paidAmount);
    put('rest_amount', restAmount);
    put('total_fees', totalFees);

    /// 🔢 order
    put('order_num', orderNum);
    put('order_reserved', orderReserved);
    put('priority_level', priorityLevel);
    put('checked_in_at', checkedInAt);
    put('missed_returned_at', missedReturnedAt);
    put('queue_reason', queueReason);

    /// 🧾 medical
    put('allergies', allergies);
    put('diagnosis', diagnosis);
    put('temperature', temperature);
    put('weight', weight);
    put('height', height);

    /// 📎 attachments
    put('transfer_image', transferImage);

    put('prescription_url_1', prescriptionUrl1);
    put('prescription_url_2', prescriptionUrl2);
    put('prescription_url_3', prescriptionUrl3);
    put('prescription_url_4', prescriptionUrl4);
    put('prescription_url_5', prescriptionUrl5);

    /// 💳 online payment
    put('payment_screenshot_url', paymentScreenshotUrl);
    put('payment_method', paymentMethod);
    put('payment_status', paymentStatus);

    /// 🗺️ clinic location
    put('clinic_address', clinicAddress);
    put('clinic_latitude', clinicLatitude);
    put('clinic_longitude', clinicLongitude);

    /// ⚙️ flags
    data['is_ordered'] = isOrdered ? 1 : 0;
    data['has_feedback'] = hasFeedback ? 1 : 0;

    return data;
  }

  // 🔹 Firebase JSON (excludes SQLite sync metadata)
  Map<String, dynamic> toFirebaseJson() {
    final data = toJson();
    data.remove('is_deleted');
    data.remove('server_updated_at');
    data.remove('updated_at');
    return data;
  }

  // 🔹 From JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt(); // Firebase stores ints as doubles
      return int.tryParse(v.toString());
    }

    bool toBool(dynamic v) {
      return v == 1 || v == true || v == "1";
    }

    return ReservationModel(
      key: json['key'],

      /// 🕒 timestamps
      createdAt: toInt(json['created_at']),
      updatedAt: toInt(json['updated_at']),
      serverUpdatedAt: toInt(json['server_updated_at']),
      isDeleted: toBool(json['is_deleted']),

      isAutoType: toBool(json["is_auto_type"]),
      revisitCount: _toInt(json["revisit_count"]),
      parentKey: json["parent_key"],

      /// 🏥 relations
      clinicKey: json['clinic_key'],
      shiftKey: json['shift_key'],
      medicalCenterKey: json['medical_center_key'],

      /// 👨‍⚕️ doctor
      doctorUid: json['doctor_uid'],
      doctorName: json['doctor_name'],
      doctorFcm: json['doctor_fcm'],

      /// 🧑‍⚕️ assistant
      assistantUid: json['assistant_uid'],
      assistantName: json['assistant_name'],
      assistantFcm: json['assistant_fcm'],

      /// 👤 patient
      patientUid: json['patient_uid'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'],
      patientFcm: json['patient_fcm'],
      patientCode: json['patient_code'],

      /// 📅 reservation
      appointmentDateTime: json['appointment_date_time'],
      status: json['status'],
      reservationType: json['reservation_type'],

      /// 💰 financial
      paidAmount: json['paid_amount'],
      restAmount: json['rest_amount'],
      totalFees: json['total_fees'],

      /// 🔢 order
      orderNum: toInt(json['order_num']),
      orderReserved: toInt(json['order_reserved']),
      priorityLevel: toInt(json['priority_level']),
      checkedInAt: toInt(json['checked_in_at']),
      missedReturnedAt: toInt(json['missed_returned_at']),
      queueReason: json['queue_reason'],

      /// 🧾 medical
      allergies: json['allergies'],
      diagnosis: json['diagnosis'],
      temperature: json['temperature'],
      weight: json['weight'],
      height: json['height'],

      /// 📎 attachments
      transferImage: json['transfer_image'],

      prescriptionUrl1: json['prescription_url_1'],
      prescriptionUrl2: json['prescription_url_2'],
      prescriptionUrl3: json['prescription_url_3'],
      prescriptionUrl4: json['prescription_url_4'],
      prescriptionUrl5: json['prescription_url_5'],

      /// 💳 online payment
      paymentScreenshotUrl: json['payment_screenshot_url'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],

      /// 🗺️ clinic location
      clinicAddress: json['clinic_address'],
      clinicLatitude: (json['clinic_latitude'] as num?)?.toDouble(),
      clinicLongitude: (json['clinic_longitude'] as num?)?.toDouble(),

      /// ⚙️ flags
      isOrdered: toBool(json['is_ordered']),
      hasFeedback: toBool(json['has_feedback']),
    );
  }

  // 🔹 CopyWith (FIXED 🔥)
  ReservationModel copyWith({
    String? key,

    /// 🕒 timestamps
    int? createdAt,
    int? updatedAt,
    int? serverUpdatedAt,
    bool? isDeleted,

    /// 🏥 relations
    String? clinicKey,
    String? shiftKey,
    String? medicalCenterKey,

    int? revisitCount,
    String? parentKey,
    bool? isAutoType,

    /// 👨‍⚕️ doctor
    String? doctorUid,
    String? doctorName,
    String? doctorFcm,

    /// 🧑‍⚕️ assistant
    String? assistantUid,
    String? assistantName,
    String? assistantFcm,

    /// 👤 patient
    String? patientUid,
    String? patientName,
    String? patientPhone,
    String? patientFcm,
    String? patientCode,

    /// 📅 reservation
    String? appointmentDateTime,
    String? status,
    String? reservationType,

    /// 💰 financial
    String? paidAmount,
    String? restAmount,
    String? totalFees,

    /// 🔢 order
    int? orderNum,
    int? orderReserved,
    int? priorityLevel,
    int? checkedInAt,
    int? missedReturnedAt,
    String? queueReason,

    /// 📎 attachments
    String? transferImage,

    String? prescriptionUrl1,
    String? prescriptionUrl2,
    String? prescriptionUrl3,
    String? prescriptionUrl4,
    String? prescriptionUrl5,

    /// 💳 online payment
    String? paymentScreenshotUrl,
    String? paymentMethod,
    String? paymentStatus,

    /// 🗺️ clinic location
    String? clinicAddress,
    double? clinicLatitude,
    double? clinicLongitude,

    /// ⚙️ flags
    bool? isOrdered,
    bool? hasFeedback,
  }) {
    return ReservationModel(
      key: key ?? this.key,

      /// 🕒 timestamps
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      revisitCount: revisitCount ?? this.revisitCount,
      isAutoType: isAutoType ?? this.isAutoType,
      parentKey: parentKey ?? this.parentKey,

      /// 🏥 relations
      clinicKey: clinicKey ?? this.clinicKey,
      shiftKey: shiftKey ?? this.shiftKey,
      medicalCenterKey: medicalCenterKey ?? this.medicalCenterKey,

      /// 👨‍⚕️ doctor
      doctorUid: doctorUid ?? this.doctorUid,
      doctorName: doctorName ?? this.doctorName,
      doctorFcm: doctorFcm ?? this.doctorFcm,

      /// 🧑‍⚕️ assistant
      assistantUid: assistantUid ?? this.assistantUid,
      assistantName: assistantName ?? this.assistantName,
      assistantFcm: assistantFcm ?? this.assistantFcm,

      /// 👤 patient
      patientUid: patientUid ?? this.patientUid,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientFcm: patientFcm ?? this.patientFcm,
      patientCode: patientCode ?? this.patientCode,

      /// 📅 reservation
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      status: status ?? this.status,
      reservationType: reservationType ?? this.reservationType,

      /// 💰 financial
      paidAmount: paidAmount ?? this.paidAmount,
      restAmount: restAmount ?? this.restAmount,
      totalFees: totalFees ?? this.totalFees,

      /// 🔢 order
      orderNum: orderNum ?? this.orderNum,
      orderReserved: orderReserved ?? this.orderReserved,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      missedReturnedAt: missedReturnedAt ?? this.missedReturnedAt,
      queueReason: queueReason ?? this.queueReason,

      /// 📎 attachments
      transferImage: transferImage ?? this.transferImage,

      prescriptionUrl1: prescriptionUrl1 ?? this.prescriptionUrl1,
      prescriptionUrl2: prescriptionUrl2 ?? this.prescriptionUrl2,
      prescriptionUrl3: prescriptionUrl3 ?? this.prescriptionUrl3,
      prescriptionUrl4: prescriptionUrl4 ?? this.prescriptionUrl4,
      prescriptionUrl5: prescriptionUrl5 ?? this.prescriptionUrl5,

      /// 💳 online payment
      paymentScreenshotUrl: paymentScreenshotUrl ?? this.paymentScreenshotUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,

      /// 🗺️ clinic location
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicLatitude: clinicLatitude ?? this.clinicLatitude,
      clinicLongitude: clinicLongitude ?? this.clinicLongitude,

      /// ⚙️ flags
      isOrdered: isOrdered ?? this.isOrdered,
      hasFeedback: hasFeedback ?? this.hasFeedback,
    );
  }
}
