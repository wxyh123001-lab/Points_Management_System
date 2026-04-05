import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _boxName = 'customers';

  Future<Box<Map>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Map>(_boxName);
    }
    return Hive.box<Map>(_boxName);
  }

  Future<List<Customer>> fetchCustomers({
    int? minPoints,
    int? maxPoints,
    int? birthMonth,
  }) async {
    final box = await _box;
    final all = box.values
        .map((e) => _mapToCustomer(Map<String, dynamic>.from(e)))
        .toList();

    return all.where((c) {
      if (minPoints != null && c.points < minPoints) return false;
      if (maxPoints != null && c.points > maxPoints) return false;
      if (birthMonth != null) {
        if (c.birthday == null) return false;
        if (c.birthday!.month != birthMonth) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
  }

  Future<Customer> createCustomer(Customer customer) async {
    final box = await _box;
    final id = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now().toIso8601String();
    final map = _customerToMap(customer);
    map['id'] = id;
    map['created_at'] = now;
    map['updated_at'] = now;
    await box.put(id, map);
    return customer.copyWith(id: id);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    assert(customer.id != null);
    final box = await _box;
    final existing = box.get(customer.id);
    final map = _customerToMap(customer);
    map['id'] = customer.id;
    map['created_at'] = existing?['created_at'] ?? DateTime.now().toIso8601String();
    map['updated_at'] = DateTime.now().toIso8601String();
    await box.put(customer.id, map);
    return customer;
  }

  Map<String, dynamic> _customerToMap(Customer c) {
    final fmt = DateFormat('yyyy-MM-dd');
    return {
      'name': c.name,
      'clothing_size': c.clothingSize,
      'points': c.points,
      'gender': c.gender,
      'birthday': c.birthday != null ? fmt.format(c.birthday!) : null,
      'phone': c.phone,
      'store_id': c.storeId,
    };
  }

  Customer _mapToCustomer(Map<String, dynamic> m) {
    return Customer(
      id: m['id'] as int?,
      name: m['name'] as String,
      clothingSize: m['clothing_size'] as String,
      points: m['points'] as int,
      gender: m['gender'] as String?,
      birthday: m['birthday'] != null ? DateTime.parse(m['birthday'] as String) : null,
      phone: m['phone'] as String?,
      storeId: m['store_id'] as int? ?? 1,
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at'] as String) : null,
      updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at'] as String) : null,
    );
  }
}
