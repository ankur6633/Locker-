import 'package:hive/hive.dart';

/// Hive model for storing user data in admin panel
class HiveUserModel extends HiveObject {
  String id;
  String name;
  String email;
  String phone;
  String password; // User password for login
  DateTime createdAt;
  bool isActive;
  String? emiId; // Reference to EMI
  bool deviceLockedByAdmin; // Device locked by admin

  HiveUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.createdAt,
    this.isActive = true,
    this.emiId,
    this.deviceLockedByAdmin = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'emiId': emiId,
        'deviceLockedByAdmin': deviceLockedByAdmin,
      };

  factory HiveUserModel.fromJson(Map<String, dynamic> json) => HiveUserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        password: json['password'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
        emiId: json['emiId'] as String?,
        deviceLockedByAdmin: json['deviceLockedByAdmin'] as bool? ?? false,
      );
}
