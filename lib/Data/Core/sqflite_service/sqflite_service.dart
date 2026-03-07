import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sqflite_database.db');

    return await openDatabase(
      path,
      version: 56, // ⬅️ زودنا الفيرجن عشان نضمن إعادة الإنشاء
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🆕 CREATE DATABASE
  // ─────────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // ===========================
    // medicines
    // ===========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
        key TEXT PRIMARY KEY,
        trade_name_en TEXT,
        trade_name_ar TEXT,
        composition TEXT,
        company TEXT,
        category TEXT,
        dosage_form TEXT,
        barcode TEXT,
        origin TEXT,
        price REAL,
        popularity INTEGER,
        search_text TEXT
      );
    ''');

    // ===========================
    // 🔥 medicines_fts (SAFE TRY)
    // ===========================
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS medicines_fts
        USING fts5(
          key,
          trade_name_en,
          trade_name_ar,
          composition,
          company,
          category,
          content='medicines',
          content_rowid='rowid'
        );
      ''');
      print("✅ FTS5 Table Created");
    } catch (e) {
      print("⚠️ FTS5 NOT SUPPORTED ON THIS DEVICE");
    }

    // ===========================
    // clients
    // ===========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        key TEXT PRIMARY KEY,
        token TEXT,
        client_name TEXT,
        phone TEXT,
        doctorQualifications TEXT,
        whats_app_phone TEXT,
        image TEXT,
        profile_image TEXT,
        cover_image TEXT,
        address TEXT,
        code TEXT,
        userType TEXT,
        doctor_key TEXT,
        doctor_name TEXT,
        sales_key TEXT,
        clinic_key TEXT,
        specialize_key TEXT,
        specialization_name TEXT,
        identifier TEXT,
        password TEXT,
        isCompleteProfile INTEGER,
        createAt INTEGER,
        transfer_number TEXT,
        is_insta_pay INTEGER DEFAULT 0,
        is_electronic_wallet INTEGER DEFAULT 0,
        show_file_number INTEGER DEFAULT 0,
        file_number INTEGER DEFAULT 0,
        remote_reservation_ability INTEGER DEFAULT 1,
        fcm_token TEXT,
        total_rate REAL DEFAULT 0.0,
        number_of_rates INTEGER DEFAULT 0,
        facebook_link TEXT,
        instagram_link TEXT,
        tiktok_link TEXT
      );
    ''');

    // ===========================
    // clinics
    // ===========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clinics (
        key TEXT PRIMARY KEY,
        title TEXT,
        dailyWorks TEXT,
        address TEXT,
        phone1 TEXT,
        phone2 TEXT,
        emergency_call TEXT,
        location TEXT,
        whatsapp_num TEXT,
        appointments TEXT,
        doctor_key TEXT,
        consultation_price TEXT,
        follow_up_price TEXT,
        urgent_consultation_price TEXT,
        reserve_with_deposit INTEGER,
        minimum_deposit_percent REAL,
        urgent_policy INTEGER,
        send_whatsapp INTEGER DEFAULT 0,
        file_number INTEGER DEFAULT 0
      );
    ''');

    // ===========================
    // reservations
    // ===========================
    await db.execute('''
  CREATE TABLE IF NOT EXISTS reservations (
    key TEXT PRIMARY KEY,

    patient_uid TEXT,
    fcmToken_patient TEXT,
    fcmToken_assist TEXT,

    create_at INTEGER,
    updated_at INTEGER,
    server_updated_at INTEGER,

    sync_status TEXT,
    is_deleted INTEGER DEFAULT 0,

    doctor_key TEXT,
    doctor_name TEXT,

    transfer_image TEXT,

    order_num INTEGER,
    order_finished INTEGER,
    order_reserved INTEGER,

    patient_key TEXT,
    assistant_key TEXT,
    shift_key TEXT,

    patient_name TEXT,
    patient_phone TEXT,

    status TEXT,

    paid_amount TEXT,
    rest_amount TEXT,
    total_fees TEXT,

    appointment_date_time TEXT,
    waiting_num TEXT,

    clinic_key TEXT,
    reservation_type TEXT,

    allergies TEXT,
    diagnosis TEXT,
    temperature TEXT,
    weight TEXT,
    height TEXT,

    prescription_url_1 TEXT,
    prescription_url_2 TEXT,

    is_ordered INTEGER DEFAULT 0,
    has_feedback INTEGER DEFAULT 0
  );
''');
    // ===========================
    // reservations_order
    // ===========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reservations_order (
        key TEXT PRIMARY KEY,
        order_num INTEGER,
        order_reserved INTEGER
      );
    ''');

    print("✅ DATABASE CREATED SUCCESSFULLY");
  }

  // ─────────────────────────────────────────────
  // 🔁 UPGRADE (CLEAN REBUILD)
  // ─────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("🔄 UPGRADING DATABASE FROM $oldVersion TO $newVersion");

    await db.execute('DROP TABLE IF EXISTS medicines;');
    await db.execute('DROP TABLE IF EXISTS medicines_fts;');
    await db.execute('DROP TABLE IF EXISTS clients;');
    await db.execute('DROP TABLE IF EXISTS reservations;');
    await db.execute('DROP TABLE IF EXISTS clinics;');
    await db.execute('DROP TABLE IF EXISTS reservations_order;');

    await _onCreate(db, newVersion);
  }

  // ─────────────────────────────────────────────
  // 🗑 DELETE DB (DEV ONLY)
  // ─────────────────────────────────────────────
  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sqflite_database.db');
    await deleteDatabase(path);
    print("🗑 DATABASE FILE DELETED");
  }

  // ─────────────────────────────────────────────
  // 🔎 CHECK TABLES
  // ─────────────────────────────────────────────
  Future<void> checkTables() async {
    final db = await database;
    final tables = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table"',
    );
    print("📋 TABLES: $tables");
  }
}
