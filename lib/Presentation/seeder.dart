import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';

import 'package:diwanclinic/Data/Core/sqflite_service/sqflite_service.dart';

class MedicineExcelSeeder {
  static Future<void> seedIfNeeded() async {
    final db = await DatabaseService().database;

    // هل الأدوية اتدخلت قبل كده؟
    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM medicines"),
    );

    if (count != null && count > 0) return;

    // ─────────────────────────────
    // 1️⃣ Load Excel
    // ─────────────────────────────
    final ByteData data = await rootBundle.load('assets/medicines.xlsx');
    final Uint8List bytes = data.buffer.asUint8List();

    final excel = Excel.decodeBytes(bytes);
    final Sheet sheet = excel.tables.values.first;

    final batch = db.batch();

    // ─────────────────────────────
    // 2️⃣ Insert into medicines
    // ─────────────────────────────
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      final id = row[0]?.value?.toString().trim();
      if (id == null || id.isEmpty) continue;

      final tradeNameEn = row[1]?.value?.toString().trim() ?? '';
      final tradeNameAr = row[2]?.value?.toString().trim() ?? '';
      final price = double.tryParse(row[3]?.value?.toString() ?? '');
      final composition = row[4]?.value?.toString().trim() ?? '';
      final company = row[5]?.value?.toString().trim() ?? '';
      final category = row[6]?.value?.toString().trim() ?? '';
      final dosageForm = row[8]?.value?.toString().trim() ?? '';
      final barcode = row[9]?.value?.toString().trim() ?? '';
      final origin = row[10]?.value?.toString().trim() ?? '';
      final popularity = int.tryParse(row[11]?.value?.toString() ?? '');

      final searchText =
          ("$tradeNameEn "
                  "$tradeNameAr "
                  "$composition "
                  "$company "
                  "$category")
              .toLowerCase();

      batch.insert('medicines', {
        'key': id,
        'trade_name_en': tradeNameEn,
        'trade_name_ar': tradeNameAr,
        'composition': composition,
        'company': company,
        'category': category,
        'dosage_form': dosageForm,
        'barcode': barcode,
        'origin': origin,
        'price': price,
        'popularity': popularity,
        'search_text': searchText,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);

    // ─────────────────────────────
    // 3️⃣ Fill FTS5 table (medicines_fts)
    // ─────────────────────────────
    await db.execute('''
      INSERT INTO medicines_fts(
        rowid,
        key,
        trade_name_en,
        trade_name_ar,
        composition,
        company,
        category
      )
      SELECT
        rowid,
        key,
        trade_name_en,
        trade_name_ar,
        composition,
        company,
        category
      FROM medicines;
    ''');
  }
}
