import '../../../index/index_main.dart';

class QueryBuilder {
  /// Build WHERE clause and WHERE args dynamically based on non-null and non-empty fields.
  static SQLiteQueryParams buildQueryFromEntity(
    dynamic entity, {
    bool? isFiltered,
    String? order_by,
    List<String>? additionalWhere, // Additional WHERE conditions
    List<Object?>? additionalWhereArgs, // Additional WHERE args
  }) {
    final List<String> whereConditions = [];
    final List<Object?> whereArgs = [];

    // Use toJson() to get all non-null and non-empty fields
    final Map<String, dynamic> entityData = entity.toJson();

    entityData.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        if (value is String) {
          value = value.trim();
        }
        whereConditions.add('$key = ?');
        whereArgs.add(value);
      }
    });

    // Add additional conditions if provided
    if (additionalWhere != null && additionalWhere.isNotEmpty) {
      whereConditions.addAll(additionalWhere);
    }

    if (additionalWhereArgs != null && additionalWhereArgs.isNotEmpty) {
      whereArgs.addAll(
        additionalWhereArgs.map((arg) => arg is String ? arg.trim() : arg),
      );
    }

    final String whereClause = whereConditions.join(' AND ');
    String order = order_by ?? "DESC";
    print("order is ${order}");

    return SQLiteQueryParams(
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      is_filtered: true,
      orderBy: order_by,
    );
  }
}
