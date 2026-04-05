import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerFilter {
  final int? minPoints;
  final int? maxPoints;
  final int? birthMonth; // 1-12，null 表示不筛选

  const CustomerFilter({this.minPoints, this.maxPoints, this.birthMonth});

  CustomerFilter copyWith({
    int? minPoints,
    int? maxPoints,
    int? birthMonth,
    bool clearMinPoints = false,
    bool clearMaxPoints = false,
    bool clearBirthMonth = false,
  }) {
    return CustomerFilter(
      minPoints: clearMinPoints ? null : (minPoints ?? this.minPoints),
      maxPoints: clearMaxPoints ? null : (maxPoints ?? this.maxPoints),
      birthMonth: clearBirthMonth ? null : (birthMonth ?? this.birthMonth),
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  final DatabaseService _service = DatabaseService();

  List<Customer> _customers = [];
  bool _loading = false;
  String? _error;
  CustomerFilter _filter = const CustomerFilter();

  List<Customer> get customers => _customers;
  bool get loading => _loading;
  String? get error => _error;
  CustomerFilter get filter => _filter;

  void setFilter(CustomerFilter filter) {
    _filter = filter;
    notifyListeners();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _service.fetchCustomers(
        minPoints: _filter.minPoints,
        maxPoints: _filter.maxPoints,
        birthMonth: _filter.birthMonth,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    final created = await _service.createCustomer(customer);
    _customers.insert(0, created);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    final updated = await _service.updateCustomer(customer);
    final idx = _customers.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) {
      _customers[idx] = updated;
      notifyListeners();
    }
  }
}
