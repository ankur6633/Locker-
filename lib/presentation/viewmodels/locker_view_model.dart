import 'package:flutter/foundation.dart';
import '../../domain/entities/emi.dart';
import '../../domain/use_cases/emi/check_emi_status_use_case.dart';
import '../../domain/use_cases/emi/get_emi_details_use_case.dart';

/// Locker Engine ViewModel
class LockerViewModel extends ChangeNotifier {
  LockerViewModel(
    this._checkEmiStatusUseCase,
    this._getEmiDetailsUseCase,
  );

  final CheckEmiStatusUseCase _checkEmiStatusUseCase;
  final GetEmiDetailsUseCase _getEmiDetailsUseCase;

  bool _isLoading = false;
  bool _isOverdue = false;
  Emi? _emi;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isOverdue => _isOverdue;
  Emi? get emi => _emi;
  String? get errorMessage => _errorMessage;

  /// Check EMI status (called on app start)
  Future<bool> checkEmiStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _checkEmiStatusUseCase();

    _isLoading = false;

    if (result.failure != null) {
      _errorMessage = result.failure!.message;
      notifyListeners();
      return false;
    }

    _isOverdue = result.isOverdue ?? false;

    if (_isOverdue) {
      // Load full EMI details for lock screen
      await _loadEmiDetails();
    }

    notifyListeners();
    return _isOverdue;
  }

  /// Load EMI details
  Future<void> _loadEmiDetails() async {
    final result = await _getEmiDetailsUseCase();
    if (result.failure == null && result.emi != null) {
      _emi = result.emi;
    }
  }

  /// Refresh EMI status
  Future<void> refresh() async {
    await checkEmiStatus();
  }
}
