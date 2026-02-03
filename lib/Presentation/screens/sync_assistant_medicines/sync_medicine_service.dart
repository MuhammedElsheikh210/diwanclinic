import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../index/index_main.dart';

class SyncMedicineService extends GetxService {
  Future<void> prepareDatabase() async {
    try {
      final dbPath = await getDatabasesPath();

      final path = join(dbPath, 'medicines.db');

      final exists = await databaseExists(path);

      if (!exists) {
        final data = await rootBundle.load('assets/medicines.db');

        final bytes = data.buffer.asUint8List();
        await File(path).writeAsBytes(bytes, flush: true);
      }
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Future<Database> openDatabaseInstance() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'medicines.db');

      final db = await openDatabase(path);

      return db;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }
}
