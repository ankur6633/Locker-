import 'package:flutter/foundation.dart';
import '../services/admin_data_service.dart';
import '../models/hive_user_model.dart';

/// ViewModel for Admin Users Management
class AdminUsersViewModel extends ChangeNotifier {
  final AdminDataService _dataService;

  AdminUsersViewModel(this._dataService);

  List<HiveUserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HiveUserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _users = _dataService.getAllUsers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new user
  Future<bool> addUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.addUser(
        name: name,
        email: email,
        phone: phone,
      );
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId) async {
    final user = _dataService.getUserById(userId);
    if (user != null) {
      user.isActive = !user.isActive;
      await _dataService.updateUser(user);
      await loadUsers();
    }
  }

  /// Refresh users list
  Future<void> refresh() async {
    await loadUsers();
  }
}
