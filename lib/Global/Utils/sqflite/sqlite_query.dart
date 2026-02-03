

import '../../Enums/FilterEnum.dart';

class SQLiteQueryParams {
  final bool? distinct;
  final bool? is_filtered;
  final List<String>? columns;
  final String? where;
  final List<Object?>? whereArgs;
  final String? groupBy;
  final String? having;
  final String? orderBy;
  final int? limit;
  final int? offset;


  SQLiteQueryParams({
    this.distinct,
    this.columns,
    this.where,
    this.is_filtered,
    this.whereArgs,
    this.groupBy,
    this.having,
    this.orderBy,
    this.limit,
    this.offset,
  });

  /// Convert the params to a readable string for debugging
  @override
  String toString() {
    return ' Distinct: $distinct, Columns: $columns, Where: $where, WhereArgs: $whereArgs, '
        'GroupBy: $groupBy, Having: $having, OrderBy: $orderBy, Limit: $limit, Offset: $offset';
  }
}
