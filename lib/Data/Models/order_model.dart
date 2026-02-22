class OrderModel {
  final String? key;
  final List<MedicineItemModel>? medicines;

  // 🔗 References
  final String? reservationKey;
  final String? patientKey;
  final String? patientuid;
  final String? patientPhone;
  final String? patientaddress;
  final String? doctorKey;
  final String? clinicKey;
  final String? fcmToken;
   String? cancel_reason;

  // 🧑‍⚕️ Names
  final String? patientName;
  final String? doctorName;

  // 🧑‍⚕️ Patient Info
  final String? phone;
  final String? whatsApp;
  final String? address;

  // 💊 Prescription Images (UP TO 5)
  final String? prescriptionUrl1;
  final String? prescriptionUrl2;
  final String? prescriptionUrl3;
  final String? prescriptionUrl4;
  final String? prescriptionUrl5;

  // Dose
  final int? doseDays;
  final int? isTransfered;

  // 💰 Financial Info
  final num? totalOrder;
  final num? deliveryFees;
  final num? discount;
  final num? finalAmount;

  // 🚚 Delivery & Pharmacy
  final String? deliveryType;
  final String? pharmacyName;
  final String? pharmacyAddress;
  final String? deliveryStatus;

  /// 🆕 Pharmacy Contact Info
  final String? pharmacyFcmToken; // NEW
  final String? pharmacyPhone; // NEW

  // 🗒️ Misc
  final String? notes;

  // ⚙️ Order Tracking
  final String? status;
  final int? createdAt;
  final String? createdBy;
  final int? updatedAt;

  OrderModel({
    this.key,
    this.patientuid,
    this.medicines,
    this.fcmToken,
    this.patientPhone,
    this.cancel_reason,
    this.patientaddress,
    this.reservationKey,
    this.patientKey,
    this.doctorKey,
    this.clinicKey,
    this.patientName,
    this.doctorName,
    this.phone,
    this.whatsApp,
    this.address,
    this.doseDays,
    this.isTransfered,
    this.prescriptionUrl1,
    this.prescriptionUrl2,
    this.prescriptionUrl3,
    this.prescriptionUrl4,
    this.prescriptionUrl5,
    this.totalOrder,
    this.deliveryFees,
    this.discount,
    this.finalAmount,
    this.deliveryType,
    this.pharmacyName,
    this.pharmacyAddress,
    this.deliveryStatus,
    this.pharmacyFcmToken, // NEW
    this.pharmacyPhone, // NEW
    this.notes,
    this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  // 🔹 Convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (key != null) data['key'] = key;
    if (cancel_reason != null) data['cancel_reason'] = cancel_reason;
    if (patientuid != null) data['patientuid'] = patientuid;
    if (patientPhone != null) data['patientPhone'] = patientPhone;
    if (patientaddress != null) data['patientaddress'] = patientaddress;
    if (fcmToken != null) data['patient_fcm_token'] = fcmToken;
    if (reservationKey != null) data['reservation_key'] = reservationKey;
    if (patientKey != null) data['patient_key'] = patientKey;
    if (doctorKey != null) data['doctor_key'] = doctorKey;
    if (clinicKey != null) data['clinic_key'] = clinicKey;

    if (medicines != null) {
      data['medicines'] = medicines!.map((e) => e.toJson()).toList();
    }

    if (patientName != null) data['patient_name'] = patientName;
    if (doctorName != null) data['doctor_name'] = doctorName;
    if (phone != null) data['phone'] = phone;
    if (whatsApp != null) data['whats_app'] = whatsApp;
    if (address != null) data['address'] = address;

    data['dose_days'] = doseDays;
    data['isTransfered'] = isTransfered;

    if (prescriptionUrl1 != null) data['prescription_url_1'] = prescriptionUrl1;
    if (prescriptionUrl2 != null) data['prescription_url_2'] = prescriptionUrl2;
    if (prescriptionUrl3 != null) data['prescription_url_3'] = prescriptionUrl3;
    if (prescriptionUrl4 != null) data['prescription_url_4'] = prescriptionUrl4;
    if (prescriptionUrl5 != null) data['prescription_url_5'] = prescriptionUrl5;

    if (totalOrder != null) data['total_order'] = totalOrder;
    if (deliveryFees != null) data['delivery_fees'] = deliveryFees;
    if (discount != null) data['discount'] = discount;
    if (finalAmount != null) data['final_amount'] = finalAmount;

    if (deliveryType != null) data['delivery_type'] = deliveryType;
    if (pharmacyName != null) data['pharmacy_name'] = pharmacyName;
    if (pharmacyAddress != null) data['pharmacy_address'] = pharmacyAddress;
    if (deliveryStatus != null) data['delivery_status'] = deliveryStatus;

    // NEW FIELDS
    if (pharmacyFcmToken != null) data['pharmacy_fcm_token'] = pharmacyFcmToken;
    if (pharmacyPhone != null) data['pharmacy_phone'] = pharmacyPhone;

    if (notes != null) data['notes'] = notes;
    if (status != null) data['status'] = status;

    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['updated_at'] = updatedAt;

    return data;
  }

  // 🔹 From JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      key: json['key'],
      cancel_reason: json['cancel_reason'],
      patientuid: json['patientuid'],
      patientPhone: json['patientPhone'],
      patientaddress: json['patientaddress'],
      fcmToken: json['patient_fcm_token'],
      reservationKey: json['reservation_key'],
      patientKey: json['patient_key'],
      doctorKey: json['doctor_key'],
      clinicKey: json['clinic_key'],

      medicines: json['medicines'] != null
          ? (json['medicines'] as List)
                .map(
                  (e) => MedicineItemModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : null,

      patientName: json['patient_name'],
      doctorName: json['doctor_name'],
      phone: json['phone'],
      whatsApp: json['whats_app'],
      address: json['address'],

      doseDays: json['dose_days'],
      isTransfered: json['isTransfered'],

      prescriptionUrl1: json['prescription_url_1'],
      prescriptionUrl2: json['prescription_url_2'],
      prescriptionUrl3: json['prescription_url_3'],
      prescriptionUrl4: json['prescription_url_4'],
      prescriptionUrl5: json['prescription_url_5'],

      totalOrder: (json['total_order'] as num?)?.toDouble(),
      deliveryFees: (json['delivery_fees'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      finalAmount: (json['final_amount'] as num?)?.toDouble(),

      deliveryType: json['delivery_type'],
      pharmacyName: json['pharmacy_name'],
      pharmacyAddress: json['pharmacy_address'],
      deliveryStatus: json['delivery_status'],

      pharmacyFcmToken: json['pharmacy_fcm_token'],
      // NEW
      pharmacyPhone: json['pharmacy_phone'],

      // NEW
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
    );
  }

  // 🔹 CopyWith
  OrderModel copyWith({
    String? key,
    String? patientUid,
    String? patientPhone,
    String? patientAddress,
    String? cancel_reason,
    String? fcmToken,
    String? reservationKey,
    String? patientKey,
    String? doctorKey,
    String? clinicKey,
    List<MedicineItemModel>? medicines,
    String? patientName,
    String? doctorName,
    String? phone,
    String? whatsApp,
    String? address,
    int? doseDays,
    int? isTransfered,
    String? prescriptionUrl1,
    String? prescriptionUrl2,
    String? prescriptionUrl3,
    String? prescriptionUrl4,
    String? prescriptionUrl5,
    num? totalOrder,
    num? deliveryFees,
    num? discount,
    num? finalAmount,
    String? deliveryType,
    String? pharmacyName,
    String? pharmacyAddress,
    String? deliveryStatus,

    // NEW
    String? pharmacyFcmToken,
    String? pharmacyPhone,

    String? notes,
    String? status,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
  }) {
    return OrderModel(
      key: key ?? this.key,
      patientuid: patientUid ?? this.patientuid,
      patientaddress: patientAddress ?? this.patientaddress,
      patientPhone: patientPhone ?? this.patientPhone,
      fcmToken: fcmToken ?? this.fcmToken,
      reservationKey: reservationKey ?? this.reservationKey,
      patientKey: patientKey ?? this.patientKey,
      doctorKey: doctorKey ?? this.doctorKey,
      clinicKey: clinicKey ?? this.clinicKey,
      medicines: medicines ?? this.medicines,
      cancel_reason: cancel_reason ?? this.cancel_reason,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      phone: phone ?? this.phone,
      whatsApp: whatsApp ?? this.whatsApp,
      address: address ?? this.address,
      doseDays: doseDays ?? this.doseDays,
      isTransfered: isTransfered ?? this.isTransfered,
      prescriptionUrl1: prescriptionUrl1 ?? this.prescriptionUrl1,
      prescriptionUrl2: prescriptionUrl2 ?? this.prescriptionUrl2,
      prescriptionUrl3: prescriptionUrl3 ?? this.prescriptionUrl3,
      prescriptionUrl4: prescriptionUrl4 ?? this.prescriptionUrl4,
      prescriptionUrl5: prescriptionUrl5 ?? this.prescriptionUrl5,
      totalOrder: totalOrder ?? this.totalOrder,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      deliveryType: deliveryType ?? this.deliveryType,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,

      pharmacyFcmToken: pharmacyFcmToken ?? this.pharmacyFcmToken,
      pharmacyPhone: pharmacyPhone ?? this.pharmacyPhone,

      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MedicineItemModel {
  final String? key;
  final String? name;
  final int? quantity;
  final num? price;
  final String? type; // مثل شريط أو كبسول أو علبة

  MedicineItemModel({
    this.key,
    this.name,
    this.quantity,
    this.price,
    this.type,
  });

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineItemModel(
      key: json['key'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'quantity': quantity,
      'price': price,
      'type': type,
    };
  }

  MedicineItemModel copyWith({
    String? key,
    String? name,
    int? quantity,
    num? price,
    String? type,
  }) {
    return MedicineItemModel(
      key: key ?? this.key,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      type: type ?? this.type,
    );
  }
}
