import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/auth/login_use_case.dart';
import '../../domain/use_cases/auth/logout_use_case.dart';

/// Authentication ViewModel
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(
    this._loginUseCase,
    this._logoutUseCase,
  );

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(email: email, password: password);

    _isLoading = false;

    if (result.failure != null) {
      _errorMessage = result.failure!.message;
      notifyListeners();
      return false;
    }

    if (result.user != null && result.token != null) {
      _user = result.user;
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Login failed';
    notifyListeners();
    return false;
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _logoutUseCase();

    _isLoading = false;
    _isLoggedIn = false;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set user (for auto-login)
  void setUser(User user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
