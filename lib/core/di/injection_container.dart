import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/local/auth_local_data_source.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/emi_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/emi_repository_impl.dart';
import '../../data/repositories/device_control_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../../core/constants/app_constants.dart';

/// Dependency injection container
final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Storage
  sl.registerLazySingleton<LocalStorage>(
    () => SecureLocalStorage(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<LocalStorage>(
    () => SharedPreferencesStorage(sl<SharedPreferences>()),
    instanceName: 'prefs',
  );

  // Initialize API Client
  final apiClient = await ApiClient.create(sl<LocalStorage>());
  sl.registerLazySingleton<ApiClient>(() => apiClient);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceMock(), // Use mock for development
    // () => AuthRemoteDataSourceImpl(sl<ApiClient>()), // Use real API in production
  );

  sl.registerLazySingleton<EmiRemoteDataSource>(
    () => EmiRemoteDataSourceMock(), // Use mock for development
    // () => EmiRemoteDataSourceImpl(sl<ApiClient>()), // Use real API in production
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sl<LocalStorage>(),
      sl<LocalStorage>(instanceName: 'prefs'),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<EmiRepository>(
    () => EmiRepositoryImpl(
      sl<EmiRemoteDataSource>(),
      sl<LocalStorage>(instanceName: 'prefs'),
    ),
  );

  sl.registerLazySingleton<DeviceControlRepository>(
    () => DeviceControlRepositoryImpl(
      MethodChannel(AppConstants.deviceControlChannel),
      MethodChannel(AppConstants.securityChannel),
    ),
  );
}
