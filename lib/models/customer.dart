import 'package:intl/intl.dart';

class Customer {
  final int? id;
  final String name;
  final String clothingSize;
  final int points;
  final String? gender;
  final DateTime? birthday;
  final String? phone;
  final int storeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    required this.clothingSize,
    required this.points,
    this.gender,
    this.birthday,
    this.phone,
    required this.storeId,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int?,
      name: json['name'] as String,
      clothingSize: json['clothing_size'] as String,
      points: json['points'] as int,
      gender: json['gender'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      phone: json['phone'] as String?,
      storeId: json['store_id'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final fmt = DateFormat('yyyy-MM-dd');
    return {
      if (id != null) 'id': id,
      'name': name,
      'clothing_size': clothingSize,
      'points': points,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': fmt.format(birthday!),
      if (phone != null) 'phone': phone,
      'store_id': storeId,
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    String? clothingSize,
    int? points,
    String? gender,
    DateTime? birthday,
    String? phone,
    int? storeId,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      clothingSize: clothingSize ?? this.clothingSize,
      points: points ?? this.points,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 返回积分里程碑等级：'bronze' / 'silver' / 'gold' / null
  static String? milestoneLevel(int points) {
    if (points >= 1000) return 'gold';
    if (points >= 800) return 'silver';
    if (points >= 500) return 'bronze';
    return null;
  }
}
