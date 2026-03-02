import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Device feature entity
class DeviceFeature extends Equatable {
  const DeviceFeature({
    required this.id,
    required this.name,
    required this.icon,
    this.isLocked = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final bool isLocked;

  DeviceFeature copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isLocked,
  }) {
    return DeviceFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, isLocked];
}

/// App entity
class AppControl extends Equatable {
  const AppControl({
    required this.id,
    required this.name,
    required this.packageName,
    required this.icon,
    this.isLocked = false,
  });

  final String id;
  final String name;
  final String packageName;
  final IconData icon;
  final bool isLocked;

  AppControl copyWith({
    String? id,
    String? name,
    String? packageName,
    IconData? icon,
    bool? isLocked,
  }) {
    return AppControl(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      icon: icon ?? this.icon,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [id, name, packageName, icon, isLocked];
}
