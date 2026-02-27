/// 🔥 Specialization Model
class SpecializationModel {
  final String key; // 👈 ده اللي بيتخزن في Firebase
  final String label; // 👈 ده اللي بيتعرض في UI

  const SpecializationModel({required this.key, required this.label});
}

/// 🔥 Specialization Mapper (Single Source of Truth)
class SpecializationMapper {
  /// 👇 كل التخصصات هنا فقط
  static const List<SpecializationModel> all = [
    SpecializationModel(key: "dentist", label: "أسنان"),
    SpecializationModel(key: "dermatology", label: "جلدية"),
    SpecializationModel(key: "pediatrics", label: "أطفال"),
    SpecializationModel(key: "orthopedic", label: "عظام"),
    SpecializationModel(key: "cardiology", label: "قلب وأوعية دموية"),
    SpecializationModel(key: "ent", label: "أنف وأذن وحنجرة"),
    SpecializationModel(key: "internal_medicine", label: "باطنة"),
    SpecializationModel(key: "general_surgery", label: "جراحة عامة"),
    SpecializationModel(key: "gynecology", label: "نساء وتوليد"),
    SpecializationModel(key: "neurology", label: "مخ وأعصاب"),
    SpecializationModel(key: "urology", label: "مسالك بولية"),
    SpecializationModel(key: "ophthalmology", label: "عيون"),
    SpecializationModel(key: "chest", label: "صدرية"),
    SpecializationModel(key: "anesthesia", label: "تخدير"),
    SpecializationModel(key: "radiology", label: "أشعة"),
    SpecializationModel(key: "oncology", label: "أورام"),
    SpecializationModel(key: "psychiatry", label: "طب نفسي"),
    SpecializationModel(key: "rheumatology", label: "روماتيزم ومناعة"),
    SpecializationModel(key: "nutrition", label: "تغذية علاجية"),
    SpecializationModel(key: "lab", label: "تحاليل طبية"),
  ];

  /// 🔹 رجّع الاسم العربي من الـ key
  static String getLabel(String? key) {
    if (key == null) return "-";

    final item = all.where((e) => e.key == key);

    if (item.isEmpty) return key; // fallback
    return item.first.label;
  }

  /// 🔹 رجّع الموديل من الـ key
  static SpecializationModel? fromKey(String? key) {
    if (key == null) return null;

    final item = all.where((e) => e.key == key);
    return item.isEmpty ? null : item.first;
  }
}
