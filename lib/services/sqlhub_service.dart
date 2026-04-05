// 已切换为本地 SQLite（database_service.dart），此文件暂不使用。
// 保留备用，以备后续多端云同步需求。
// ignore_for_file: unused_import, dead_code
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class SqlhubService {
  static const _base = 'YOUR_SQLHUB_ENDPOINT';
  static const _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_SQLHUB_API_KEY',
  };

  /// 查询顾客列表，支持积分和生日月份筛选
  Future<List<Customer>> fetchCustomers({
    int? minPoints,
    int? maxPoints,
    int? birthMonth,
  }) async {
    final params = <String, String>{};
    if (minPoints != null) params['points_gte'] = minPoints.toString();
    if (maxPoints != null) params['points_lte'] = maxPoints.toString();
    if (birthMonth != null) params['birth_month'] = birthMonth.toString();

    final uri = Uri.parse('$_base/customers').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('fetchCustomers failed: ${response.statusCode} ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 新增顾客，返回服务端写入后的完整记录（含 id/created_at/updated_at）
  Future<Customer> createCustomer(Customer customer) async {
    final uri = Uri.parse('$_base/customers');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('createCustomer failed: ${response.statusCode} ${response.body}');
    }

    return Customer.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// 更新顾客，customer.id 必须不为 null
  Future<Customer> updateCustomer(Customer customer) async {
    assert(customer.id != null, 'updateCustomer: id must not be null');
    final uri = Uri.parse('$_base/customers/${customer.id}');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('updateCustomer failed: ${response.statusCode} ${response.body}');
    }

    return Customer.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
