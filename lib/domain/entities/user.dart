import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
  });

  final String id;
  final String email;
  final String name;
  final String? phoneNumber;

  @override
  List<Object?> get props => [id, email, name, phoneNumber];
}
