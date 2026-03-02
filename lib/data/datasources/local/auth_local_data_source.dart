import 'dart:convert';
import '../../models/user_model.dart';
import '../../../domain/entities/user.dart';
import '../../../core/constants/app_constants.dart';
import 'local_storage.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveLoginStatus(bool isLoggedIn);
  Future<bool> getLoginStatus();
}

/// Implementation of AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage, this._prefsStorage);

  final LocalStorage _secureStorage; // For tokens
  final LocalStorage _prefsStorage; // For user data and login status

  @override
  Future<void> saveUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    final jsonString = jsonEncode(userModel.toJson());
    await _prefsStorage.saveString(AppConstants.userKey, jsonString);
  }

  @override
  Future<User?> getUser() async {
    try {
      final userJson = await _prefsStorage.getString(AppConstants.userKey);
      if (userJson == null) return null;
      final jsonMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _prefsStorage.remove(AppConstants.userKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.saveString(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.getString(AppConstants.tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.remove(AppConstants.tokenKey);
  }

  @override
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _prefsStorage.saveString(AppConstants.isLoggedInKey, isLoggedIn.toString());
  }

  @override
  Future<bool> getLoginStatus() async {
    final status = await _prefsStorage.getString(AppConstants.isLoggedInKey);
    return status == 'true';
  }
}
