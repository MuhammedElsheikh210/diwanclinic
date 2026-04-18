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
      version: 71, // ⬅️ bumped
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
    await _createMedicines(db);
    await _createClients(db);
    await _createClinics(db);
    await _createReservations(db);
    await _createReservationsOrder(db);

    
  }

  // ─────────────────────────────────────────────
  // 💊 MEDICINES
  // ─────────────────────────────────────────────
  Future<void> _createMedicines(Database db) async {
    await db.execute('''
      CREATE TABLE medicines (
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

    try {
      await db.execute('''
        CREATE VIRTUAL TABLE medicines_fts
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
    } catch (_) {}
  }

  Future<void> _createClients(Database db) async {
    await db.execute('''
  CREATE TABLE clients (
    key TEXT PRIMARY KEY,

    -- 🔥 BaseUser
    uid TEXT,
    createdAt INTEGER,
    userType TEXT,
    isCompleteProfile INTEGER,
    fcm_token TEXT,
    app_version TEXT,
    identifier TEXT,
    profile_image TEXT,
    phone TEXT,
    name TEXT,
    address TEXT,
    password TEXT,

    -- 🔥 AssistantUser
    clinic_key TEXT,
    doctor_key TEXT,
    doctor_name TEXT, -- 🔥 NEW
    doctor_fcm TEXT,  -- 🔥 (مهم للمستقبل)
    transfer_number TEXT,
    is_insta_pay INTEGER DEFAULT 0,

    -- 🔥 DoctorUser
    specialization_name TEXT,
    specialize_key TEXT,
    doctorQualifications TEXT,
    facebook_link TEXT,
    instagram_link TEXT,
    tiktok_link TEXT,
    total_rate REAL DEFAULT 0.0,
    number_of_rates INTEGER DEFAULT 0,
    remote_reservation_ability INTEGER DEFAULT 0,

    -- 🔥 Sync
    serverUpdatedAt INTEGER,
    updatedAt INTEGER,
    is_deleted INTEGER DEFAULT 0
  );
  ''');
  }

  // ─────────────────────────────────────────────
  // 🏥 CLINICS
  // ─────────────────────────────────────────────
  Future<void> _createClinics(Database db) async {
    await db.execute('''
      CREATE TABLE clinics (
        uid TEXT PRIMARY KEY,
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
  }

  // ─────────────────────────────────────────────
  // 📅 RESERVATIONS (SYNC READY)
  // ─────────────────────────────────────────────
  Future<void> _createReservations(Database db) async {
    await db.execute('''
CREATE TABLE reservations (
  key TEXT PRIMARY KEY,

  -- 🕒 timestamps
  created_at INTEGER,
  updated_at INTEGER NOT NULL DEFAULT 0,
  server_updated_at INTEGER,
  is_deleted INTEGER DEFAULT 0,

  -- 🏥 relations
  clinic_key TEXT,
  shift_key TEXT,
  medical_center_key TEXT,
  
  revisit_count INTEGER,
parent_key TEXT,
is_auto_type INTEGER DEFAULT 0,

  -- 👨‍⚕️ doctor
  doctor_uid TEXT,
  doctor_name TEXT,
  doctor_fcm TEXT,

  -- 🧑‍⚕️ assistant
  assistant_uid TEXT,
  assistant_name TEXT,
  assistant_fcm TEXT,

  -- 👤 patient
  patient_uid TEXT,
  patient_name TEXT,
  patient_phone TEXT,
  patient_fcm TEXT,

  -- 📅 reservation
  appointment_date_time TEXT,
  status TEXT,
  reservation_type TEXT,

  -- 💰 financial
  paid_amount TEXT,
  rest_amount TEXT,
  total_fees TEXT,

  -- 🔢 order
  order_num INTEGER,
  order_reserved INTEGER,

  -- 🧾 medical
  allergies TEXT,
  diagnosis TEXT,
  temperature TEXT,
  weight TEXT,
  height TEXT,

  -- 📎 attachments
  transfer_image TEXT,

  prescription_url_1 TEXT,
  prescription_url_2 TEXT,
  prescription_url_3 TEXT,
  prescription_url_4 TEXT,
  prescription_url_5 TEXT,

  -- ⚙️ flags
  is_ordered INTEGER DEFAULT 0,
  has_feedback INTEGER DEFAULT 0
);
''');
  }

  // ─────────────────────────────────────────────
  // 🔢 RESERVATION ORDER
  // ─────────────────────────────────────────────
  Future<void> _createReservationsOrder(Database db) async {
    await db.execute('''
      CREATE TABLE reservations_order (
        key TEXT PRIMARY KEY,
        order_num INTEGER,
        order_reserved INTEGER
      );
    ''');
  }

  // ─────────────────────────────────────────────
  // 🔁 UPGRADE
  // ─────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    

    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS medicines;');
      await txn.execute('DROP TABLE IF EXISTS medicines_fts;');
      await txn.execute('DROP TABLE IF EXISTS clients;');
      await txn.execute('DROP TABLE IF EXISTS reservations;');
      await txn.execute('DROP TABLE IF EXISTS clinics;');
      await txn.execute('DROP TABLE IF EXISTS reservations_order;');
    });

    await _onCreate(db, newVersion);
  }

  // ─────────────────────────────────────────────
  // 🗑 DELETE DB (DEV ONLY)
  // ─────────────────────────────────────────────
  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sqflite_database.db');
    await deleteDatabase(path);
  }

  // ─────────────────────────────────────────────
  // 🔎 DEBUG TABLES
  // ─────────────────────────────────────────────
  Future<void> checkTables() async {
    final db = await database;
    final tables = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table"',
    );
    
  }
}
