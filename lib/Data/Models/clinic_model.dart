class ClinicModel {
  final String? key;
  final String? title;
  final String? address;
  final String? phone1;
  final String? phone2;
  final String? emergencyCall;
  final String? location;
  final String? whatsappNum;
  final String? appointments;
  final String? doctorKey;

  // 🔹 Consultation prices
  final String? consultationPrice;
  final String? followUpPrice;
  final String? dailyWorks;
  final String? urgentConsultationPrice;

  // 🔹 Deposit settings
  final int? reserveWithDeposit;
  final double? minimumDepositPercent;

  // 🔹 Policy
  final int? urgentPolicy;

  // 🔹 WhatsApp Auto-sender
  final int? sendWhatsapp;

  // 🔹 NEW FIELD
  final int? file_number; // ✅ NEW FIELD

  ClinicModel({
    this.key,
    this.title,
    this.dailyWorks,
    this.address,
    this.phone1,
    this.phone2,
    this.emergencyCall,
    this.location,
    this.whatsappNum,
    this.appointments,
    this.doctorKey,
    this.consultationPrice,
    this.followUpPrice,
    this.urgentConsultationPrice,
    this.reserveWithDeposit,
    this.minimumDepositPercent,
    this.urgentPolicy,
    this.sendWhatsapp,
    this.file_number, // ✅ NEW
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key?.isNotEmpty == true) data['key'] = key;
    if (dailyWorks?.isNotEmpty == true) data['dailyWorks'] = dailyWorks;
    if (title?.isNotEmpty == true) data['title'] = title;
    if (address?.isNotEmpty == true) data['address'] = address;
    if (phone1?.isNotEmpty == true) data['phone1'] = phone1;
    if (phone2?.isNotEmpty == true) data['phone2'] = phone2;
    if (emergencyCall?.isNotEmpty == true)
      data['emergency_call'] = emergencyCall;
    if (location?.isNotEmpty == true) data['location'] = location;
    if (whatsappNum?.isNotEmpty == true) data['whatsapp_num'] = whatsappNum;
    if (appointments?.isNotEmpty == true) data['appointments'] = appointments;
    if (doctorKey?.isNotEmpty == true) data['doctor_key'] = doctorKey;

    if (consultationPrice?.isNotEmpty == true)
      data['consultation_price'] = consultationPrice;

    if (followUpPrice?.isNotEmpty == true)
      data['follow_up_price'] = followUpPrice;

    if (urgentConsultationPrice?.isNotEmpty == true)
      data['urgent_consultation_price'] = urgentConsultationPrice;

    if (reserveWithDeposit != null)
      data['reserve_with_deposit'] = reserveWithDeposit;

    if (minimumDepositPercent != null)
      data['minimum_deposit_percent'] = minimumDepositPercent;

    if (urgentPolicy != null) data['urgent_policy'] = urgentPolicy;

    if (sendWhatsapp != null) data['send_whatsapp'] = sendWhatsapp;

    if (file_number != null) data['file_number'] = file_number; // ✅ NEW

    return data;
  }

  /// ✅ Create Model from JSON
  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      key: json['key'],
      title: json['title'],
      dailyWorks: json['dailyWorks'],
      address: json['address'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      emergencyCall: json['emergency_call'],
      location: json['location'],
      whatsappNum: json['whatsapp_num'],
      appointments: json['appointments'],
      doctorKey: json['doctor_key'],

      consultationPrice: json['consultation_price'],
      followUpPrice: json['follow_up_price'],
      urgentConsultationPrice: json['urgent_consultation_price'],

      reserveWithDeposit: json['reserve_with_deposit'],
      minimumDepositPercent: (json['minimum_deposit_percent'] != null)
          ? (json['minimum_deposit_percent'] as num).toDouble()
          : null,

      urgentPolicy: json['urgent_policy'] is String
          ? int.tryParse(json['urgent_policy'])
          : json['urgent_policy'],

      sendWhatsapp: json['send_whatsapp'],

      file_number: json['file_number'], // ✅ NEW
    );
  }

  /// ✅ CopyWith
  ClinicModel copyWith({
    String? key,
    String? title,
    String? daillyWork,
    String? address,
    String? phone1,
    String? phone2,
    String? emergencyCall,
    String? location,
    String? whatsappNum,
    String? appointments,
    String? doctorKey,
    String? consultationPrice,
    String? followUpPrice,
    String? urgentConsultationPrice,
    int? reserveWithDeposit,
    double? minimumDepositPercent,
    int? urgentPolicy,
    int? sendWhatsapp,
    int? file_number, // ✅ NEW
  }) {
    return ClinicModel(
      key: key ?? this.key,
      dailyWorks: daillyWork ?? this.dailyWorks,
      title: title ?? this.title,
      address: address ?? this.address,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      emergencyCall: emergencyCall ?? this.emergencyCall,
      location: location ?? this.location,
      whatsappNum: whatsappNum ?? this.whatsappNum,
      appointments: appointments ?? this.appointments,
      doctorKey: doctorKey ?? this.doctorKey,
      consultationPrice: consultationPrice ?? this.consultationPrice,
      followUpPrice: followUpPrice ?? this.followUpPrice,
      urgentConsultationPrice:
          urgentConsultationPrice ?? this.urgentConsultationPrice,
      reserveWithDeposit: reserveWithDeposit ?? this.reserveWithDeposit,
      minimumDepositPercent:
          minimumDepositPercent ?? this.minimumDepositPercent,
      urgentPolicy: urgentPolicy ?? this.urgentPolicy,
      sendWhatsapp: sendWhatsapp ?? this.sendWhatsapp,
      file_number: file_number ?? this.file_number, // ✅ NEW
    );
  }
}
