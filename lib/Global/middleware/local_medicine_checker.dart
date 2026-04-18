import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalMedicineChecker {
  static Future<bool> hasValidLocalDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicines.db');

    final exists = await databaseExists(path);
    if (!exists) return false;

    final db = await openDatabase(path, readOnly: true);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM medicines',
    );
    

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
