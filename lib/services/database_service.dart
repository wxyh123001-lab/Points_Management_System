import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clothing_points.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            clothing_size TEXT NOT NULL,
            points INTEGER NOT NULL,
            gender TEXT,
            birthday TEXT,
            phone TEXT,
            store_id INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Customer>> fetchCustomers({
    int? minPoints,
    int? maxPoints,
    int? birthMonth,
  }) async {
    final database = await db;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (minPoints != null) {
      conditions.add('points >= ?');
      args.add(minPoints);
    }
    if (maxPoints != null) {
      conditions.add('points <= ?');
      args.add(maxPoints);
    }
    if (birthMonth != null) {
      conditions.add("CAST(strftime('%m', birthday) AS INTEGER) = ?");
      args.add(birthMonth);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final rows = await database.query(
      'customers',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return rows.map(_rowToCustomer).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();
    final map = _customerToRow(customer);
    map['created_at'] = now;
    map['updated_at'] = now;

    final id = await database.insert('customers', map);
    return customer.copyWith(id: id);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    assert(customer.id != null, 'updateCustomer: id must not be null');
    final database = await db;
    final map = _customerToRow(customer);
    map['updated_at'] = DateTime.now().toIso8601String();

    await database.update(
      'customers',
      map,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    return customer;
  }

  Map<String, dynamic> _customerToRow(Customer c) {
    return {
      'name': c.name,
      'clothing_size': c.clothingSize,
      'points': c.points,
      'gender': c.gender,
      'birthday': c.birthday?.toIso8601String().substring(0, 10),
      'phone': c.phone,
      'store_id': c.storeId,
    };
  }

  Customer _rowToCustomer(Map<String, dynamic> row) {
    return Customer(
      id: row['id'] as int?,
      name: row['name'] as String,
      clothingSize: row['clothing_size'] as String,
      points: row['points'] as int,
      gender: row['gender'] as String?,
      birthday: row['birthday'] != null
          ? DateTime.parse(row['birthday'] as String)
          : null,
      phone: row['phone'] as String?,
      storeId: row['store_id'] as int? ?? 1,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }
}
