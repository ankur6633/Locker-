import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
  });

  final String id;
  final String email;
  final String name;
  final String role;      // ✅ Role added
  final String? phoneNumber;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,          // ✅ MUST include
    phoneNumber,
  ];
}