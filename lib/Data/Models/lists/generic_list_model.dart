class GenericListModel {
  final String? key; // New field: key
  final int? id;
  final String? name;
  final String? name_ar;
  final String? category_type;
  final String? text;
  final int? is_packaging;
  final String? totalAmount; // New field: totalAmount

  GenericListModel({
    this.key,
    this.id,
    this.name,
    this.name_ar,
    this.text,
    this.category_type,
    this.is_packaging,
    this.totalAmount,
  });

  // Factory method to create an instance from JSON
  factory GenericListModel.fromJson(Map<String, dynamic> json) {
    return GenericListModel(
      key: json['key'] as String?, // reading key from JSON
      id: json['id'] as int?,
      category_type: json['category_type'] as String?,
      name: json['name'] as String?,
      is_packaging: json['is_packaging'] as int?,
      text: json['text'] as String?,
      totalAmount: json['total_amount'] as String?,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key, // including key in JSON
      'id': id,
      'category_type': category_type,
      'is_packaging': is_packaging,
      'name': name,
      'text': text,
      'total_amount': totalAmount,
    };
  }

  // ✅ CopyWith method
  GenericListModel copyWith({
    String? key,
    int? id,
    String? name,
    String? name_ar,
    String? category_type,
    String? text,
    int? is_packaging,
    String? totalAmount,
  }) {
    return GenericListModel(
      key: key ?? this.key,
      id: id ?? this.id,
      name: name ?? this.name,
      name_ar: name_ar ?? this.name_ar,
      category_type: category_type ?? this.category_type,
      text: text ?? this.text,
      is_packaging: is_packaging ?? this.is_packaging,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}


// Function to parse a list of JSON objects into a list of GenericListModel instances
List<GenericListModel> parseAuthList(List<dynamic> jsonList) {
  return jsonList.map((json) => GenericListModel.fromJson(json)).toList();
}

T findModelById<T extends GenericListModel>(List<T> list, int id) {
  try {
    return list.firstWhere(
          (model) => model.id == id,
      orElse: () => throw Exception('Model with id $id not found'),
    );
  } catch (e) {
    throw Exception('Error: $e');
  }
}
