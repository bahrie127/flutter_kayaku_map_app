import 'dart:convert';

class RitelModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String city;
  final String province;
  final bool? isMockGps;
  final bool? isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  RitelModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.province,
    this.isMockGps,
    this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat object dari JSON
  factory RitelModel.fromJson(Map<String, dynamic> json) {
    return RitelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      city: json['city'] as String,
      province: json['province'] as String,
      isMockGps: _parseBool(json['is_mock_gps']),
      isVerified: _parseBool(json['is_verified']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper method untuk parse double dari dynamic (bisa String atau num)
  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    } else {
      throw FormatException('Cannot parse $value to double');
    }
  }

  // Helper method untuk parse bool dari dynamic (bisa int, bool, String, atau null)
  static bool? _parseBool(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1;
    } else if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    } else {
      throw FormatException('Cannot parse $value to bool');
    }
  }

  // Factory constructor dari raw JSON string
  factory RitelModel.fromRawJson(String str) =>
      RitelModel.fromJson(json.decode(str));

  // Method untuk convert object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'province': province,
      'is_mock_gps': isMockGps,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Method untuk convert object ke raw JSON string
  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'RitelModel{id: $id, name: $name, city: $city}';
  }
}
