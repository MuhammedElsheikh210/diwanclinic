class MedicineModel {
  final int id;
  final String name; // English name
  final String? arabic; // Arabic name
  final String? company;
  final String? description;
  final String? dosageForm;
  final num? price;
  final int? soldTimes;
  final int? units;
  final String? barcode;
  final String? active;
  final String? imported;
  final int? dateUpdated;

  MedicineModel({
    required this.id,
    required this.name,
    this.arabic,
    this.company,
    this.description,
    this.dosageForm,
    this.price,
    this.soldTimes,
    this.units,
    this.barcode,
    this.active,
    this.imported,
    this.dateUpdated,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {

    return MedicineModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      arabic: json['arabic'],
      company: json['company'],
      description: json['description'],
      dosageForm: json['dosage_form'],
      price: json['price'],
      soldTimes: json['sold_times'],
      units: json['units'],
      barcode: json['barcode'],
      active: json['active'],
      imported: json['imported'],
      dateUpdated: json['Date_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'company': company,
      'description': description,
      'dosage_form': dosageForm,
      'price': price,
      'sold_times': soldTimes,
      'units': units,
      'barcode': barcode,
      'active': active,
      'imported': imported,
      'Date_updated': dateUpdated,
    };
  }
}
