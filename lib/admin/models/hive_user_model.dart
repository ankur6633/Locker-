import 'package:hive/hive.dart';

/// Hive model for storing user data in admin panel
class HiveUserModel extends HiveObject {
  String id;
  String name;
  String email;
  String phone;
  DateTime createdAt;
  bool isActive;
  String? emiId; // Reference to EMI

  HiveUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.isActive = true,
    this.emiId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'emiId': emiId,
      };

  factory HiveUserModel.fromJson(Map<String, dynamic> json) => HiveUserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
        emiId: json['emiId'] as String?,
      );
}
