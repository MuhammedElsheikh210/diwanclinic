import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../index/index_main.dart';

class MedicineDataSourceRepoImpl extends MedicineDataSourceRepo {
  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicines.db');

    _db = await openDatabase(path, readOnly: true);

    return _db!;
  }

  @override
  Future<List<MedicineModel>> searchMedicines(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) return [];

    final db = await _getDb();

    final result = await db.rawQuery(
      '''
      SELECT *
      FROM medicines
      WHERE name LIKE ?
      ORDER BY sold_times DESC
      LIMIT 30;
      ''',
      ['$q%'],
    );
    print(" list is ${result.map(MedicineModel.fromJson).toList()}");
    return result.map(MedicineModel.fromJson).toList();
  }
}
