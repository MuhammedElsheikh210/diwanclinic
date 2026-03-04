enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete, failed }

SyncStatus syncStatusFromString(String? value) {
  switch (value) {
    case 'pending_create':
      return SyncStatus.pendingCreate;
    case 'pending_update':
      return SyncStatus.pendingUpdate;
    case 'pending_delete':
      return SyncStatus.pendingDelete;
    case 'failed':
      return SyncStatus.failed;
    default:
      return SyncStatus.synced;
  }
}

String syncStatusToString(SyncStatus status) {
  switch (status) {
    case SyncStatus.pendingCreate:
      return 'pending_create';
    case SyncStatus.pendingUpdate:
      return 'pending_update';
    case SyncStatus.pendingDelete:
      return 'pending_delete';
    case SyncStatus.failed:
      return 'failed';
    case SyncStatus.synced:
    default:
      return 'synced';
  }
}

class ReservationModel {
  final String? key;
  final int? createAt;
  final String? doctorKey;
  final String? doctorName;
  final String? transfer_image;
  final String? assistantKey;
  final String? clinicKey;
  final String? shiftKey;
  final String? patientKey;
  final String? patientName;
  final String? patientPhone;
  final String? paidAmount;
  final String? restAmount;
  String? fcmToken_patient;
  String? fcmToken_assist;
  final String? totalFees;
  final String? appointmentDateTime;
  String? status;
  int? order_num;
  final int? order_finished;

  // 🔥 OFFLINE SYNC FIELDS
  SyncStatus syncStatus;
  int? updatedAt; // local update timestamp
  int? serverUpdatedAt; // last known server timestamp
  bool isDeleted;

  // 🆕 NEW — تم إضافته
  final int? order_reserved;
  final String? patientUid; // 🆕 Firebase Auth UID

  final String? reservationType;

  // الكشف
  String? temperature;
  String? weight;
  String? height;
  String? diagnosis;
  String? allergies;

  // 💊 Prescription Images (UPDATED TO 5)
  String? prescriptionUrl1;
  String? prescriptionUrl2;
  String? prescriptionUrl3;
  String? prescriptionUrl4;
  String? prescriptionUrl5;

  // NEW
  bool? isOrdered;

  // NEW — هل تم التقييم؟
  bool? hasFeedback;

  ReservationModel({
    this.key,
    this.transfer_image,
    this.createAt,
    this.doctorKey,
    this.doctorName,
    this.fcmToken_patient,
    this.fcmToken_assist,
    this.patientName,
    this.patientPhone,
    this.syncStatus = SyncStatus.synced,
    this.updatedAt,
    this.serverUpdatedAt,
    this.isDeleted = false,
    this.order_num,
    this.shiftKey,
    this.patientUid,
    this.patientKey,
    this.assistantKey,
    this.order_finished,
    this.order_reserved, // 🆕 NEW
    this.status,
    this.paidAmount,
    this.allergies,
    this.diagnosis,
    this.restAmount,
    this.totalFees,
    this.appointmentDateTime,
    this.clinicKey,
    this.reservationType,
    this.temperature,
    this.weight,
    this.height,
    // UPDATED
    this.prescriptionUrl1,
    this.prescriptionUrl2,
    this.prescriptionUrl3,
    this.prescriptionUrl4,
    this.prescriptionUrl5,

    this.isOrdered = false,
    this.hasFeedback = false,
  });

  // Helper
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // 🔹 Convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sync_status'] = syncStatusToString(syncStatus);
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (serverUpdatedAt != null) data['server_updated_at'] = serverUpdatedAt;
    data['is_deleted'] = isDeleted ? 1 : 0;

    if (key?.isNotEmpty == true) data['key'] = key;
    if (fcmToken_patient?.isNotEmpty == true)
      data['fcmToken_patient'] = fcmToken_patient;
    if (fcmToken_assist?.isNotEmpty == true)
      data['fcmToken_assist'] = fcmToken_assist;
    if (transfer_image?.isNotEmpty == true)
      data['transfer_image'] = transfer_image;
    if (order_num != null) data['order_num'] = order_num;
    if (order_finished != null) data['order_finished'] = order_finished;

    // 🆕 NEW
    if (order_reserved != null) data['order_reserved'] = order_reserved;

    if (createAt != null) data['create_at'] = createAt;
    if (shiftKey?.isNotEmpty == true) data['shift_key'] = shiftKey;
    if (patientName?.isNotEmpty == true) data['patient_name'] = patientName;
    if (patientPhone?.isNotEmpty == true) data['patient_phone'] = patientPhone;
    if (doctorKey?.isNotEmpty == true) data['doctor_key'] = doctorKey;
    if (doctorName?.isNotEmpty == true) data['doctor_name'] = doctorName;
    if (patientKey?.isNotEmpty == true) data['patient_key'] = patientKey;
    if (patientUid?.isNotEmpty == true) data['patient_uid'] = patientUid;
    if (assistantKey?.isNotEmpty == true) data['assistant_key'] = assistantKey;
    if (status?.isNotEmpty == true) data['status'] = status;
    if (paidAmount?.isNotEmpty == true) data['paid_amount'] = paidAmount;
    if (restAmount?.isNotEmpty == true) data['rest_amount'] = restAmount;
    if (totalFees?.isNotEmpty == true) data['total_fees'] = totalFees;
    if (appointmentDateTime?.isNotEmpty == true) {
      data['appointment_date_time'] = appointmentDateTime;
    }
    if (clinicKey?.isNotEmpty == true) data['clinic_key'] = clinicKey;
    if (reservationType?.isNotEmpty == true) {
      data['reservation_type'] = reservationType;
    }
    if (temperature?.isNotEmpty == true) data['temperature'] = temperature;
    if (weight?.isNotEmpty == true) data['weight'] = weight;
    if (height?.isNotEmpty == true) data['height'] = height;
    // UPDATED 5 PRESCRIPTION URLS
    if (prescriptionUrl1 != null) data['prescription_url_1'] = prescriptionUrl1;
    if (prescriptionUrl2 != null) data['prescription_url_2'] = prescriptionUrl2;
    if (prescriptionUrl3 != null) data['prescription_url_3'] = prescriptionUrl3;
    if (prescriptionUrl4 != null) data['prescription_url_4'] = prescriptionUrl4;
    if (prescriptionUrl5 != null) data['prescription_url_5'] = prescriptionUrl5;

    data['is_ordered'] = (isOrdered ?? false) ? 1 : 0;
    data['has_feedback'] = (hasFeedback ?? false) ? 1 : 0;

    return data;
  }

  // 🔹 From JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      key: json['key'],
      syncStatus: syncStatusFromString(json['sync_status']),
      updatedAt: _toInt(json['updated_at']),
      serverUpdatedAt: _toInt(json['server_updated_at']),
      isDeleted:
          json['is_deleted'] == 1 ||
          json['is_deleted'] == true ||
          json['is_deleted'] == "1",
      fcmToken_patient: json['fcmToken_patient'],
      fcmToken_assist: json['fcmToken_assist'],
      patientUid: json['patient_uid'],
      transfer_image: json['transfer_image'],
      order_num: _toInt(json['order_num']),
      order_finished: _toInt(json['order_finished']),

      // 🆕 NEW
      order_reserved: _toInt(json['order_reserved']),

      shiftKey: json['shift_key'],
      allergies: json['allergies'],
      diagnosis: json['diagnosis'],
      createAt: _toInt(json['create_at']),
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'],
      doctorKey: json['doctor_key'],
      doctorName: json['doctor_name'],
      patientKey: json['patient_key'],
      assistantKey: json['assistant_key'],
      status: json['status'],
      paidAmount: json['paid_amount'],
      restAmount: json['rest_amount'],
      totalFees: json['total_fees'],
      appointmentDateTime: json['appointment_date_time'],
      clinicKey: json['clinic_key'],
      reservationType: json['reservation_type'],
      temperature: json['temperature'],
      weight: json['weight'],
      height: json['height'],
      // UPDATED 5 URLS
      prescriptionUrl1: json['prescription_url_1'],
      prescriptionUrl2: json['prescription_url_2'],
      prescriptionUrl3: json['prescription_url_3'],
      prescriptionUrl4: json['prescription_url_4'],
      prescriptionUrl5: json['prescription_url_5'],
      isOrdered:
          json['is_ordered'] == 1 ||
          json['is_ordered'] == true ||
          json['is_ordered'] == "1",
      hasFeedback:
          json['has_feedback'] == 1 ||
          json['has_feedback'] == true ||
          json['has_feedback'] == "1",
    );
  }

  // 🔹 CopyWith
  ReservationModel copyWith({
    String? key,
    String? fcmTokenPatient,
    String? fcmTokenAssist,
    String? patientUid,
    SyncStatus? syncStatus,
    int? updatedAt,
    int? serverUpdatedAt,
    bool? isDeleted,
    String? transfer_image,
    int? createAt,
    int? order_finished,
    int? order_reserved, // 🆕 NEW
    String? shiftKey,
    int? order_num,
    String? patientName,
    String? patientPhone,
    String? doctorKey,
    String? doctorName,
    String? patientKey,
    String? assistantKey,
    String? allergies,
    String? diagnosis,
    String? status,
    String? paidAmount,
    String? restAmount,
    String? totalFees,
    String? appointmentDateTime,
    String? clinicKey,
    String? reservationType,
    String? temperature,
    String? weight,
    String? height,
    // UPDATED
    String? prescriptionUrl1,
    String? prescriptionUrl2,
    String? prescriptionUrl3,
    String? prescriptionUrl4,
    String? prescriptionUrl5,
    bool? isOrdered,
    bool? hasFeedback,
  }) {
    return ReservationModel(
      key: key ?? this.key,
      fcmToken_assist: fcmTokenAssist ?? this.fcmToken_assist,
      fcmToken_patient: fcmTokenPatient ?? this.fcmToken_patient,
      patientUid: patientUid ?? this.patientUid,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      transfer_image: transfer_image ?? this.transfer_image,
      order_num: order_num ?? this.order_num,
      order_finished: order_finished ?? this.order_finished,
      order_reserved: order_reserved ?? this.order_reserved,
      // 🆕 NEW
      createAt: createAt ?? this.createAt,
      shiftKey: shiftKey ?? this.shiftKey,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorKey: doctorKey ?? this.doctorKey,
      doctorName: doctorName ?? this.doctorName,
      patientKey: patientKey ?? this.patientKey,
      allergies: allergies ?? this.allergies,
      diagnosis: diagnosis ?? this.diagnosis,
      assistantKey: assistantKey ?? this.assistantKey,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      restAmount: restAmount ?? this.restAmount,
      totalFees: totalFees ?? this.totalFees,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      clinicKey: clinicKey ?? this.clinicKey,
      reservationType: reservationType ?? this.reservationType,
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      prescriptionUrl1: prescriptionUrl1 ?? this.prescriptionUrl1,
      prescriptionUrl2: prescriptionUrl2 ?? this.prescriptionUrl2,
      prescriptionUrl3: prescriptionUrl3 ?? this.prescriptionUrl3,
      prescriptionUrl4: prescriptionUrl4 ?? this.prescriptionUrl4,
      prescriptionUrl5: prescriptionUrl5 ?? this.prescriptionUrl5,
      isOrdered: isOrdered ?? this.isOrdered,
      hasFeedback: hasFeedback ?? this.hasFeedback,
    );
  }
}
