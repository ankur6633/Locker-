import 'package:flutter/foundation.dart';
import '../services/admin_data_service.dart';
import '../models/hive_emi_model.dart';

/// ViewModel for Admin EMI Management
class AdminEmiViewModel extends ChangeNotifier {
  final AdminDataService _dataService;

  AdminEmiViewModel(this._dataService);

  List<HiveEmiModel> _emis = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HiveEmiModel> get emis => _emis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all EMI records
  Future<void> loadEmis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _emis = _dataService.getAllEmis();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load EMI records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create EMI for user
  Future<bool> createEmi({
    required String userId,
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime startDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.createEmi(
        userId: userId,
        principalAmount: principalAmount,
        annualInterestRate: annualInterestRate,
        tenureMonths: tenureMonths,
        startDate: startDate,
      );
      await loadEmis();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create EMI: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle EMI lock status
  Future<void> toggleEmiLock(String emiId, bool lock) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dataService.toggleEmiLock(emiId, lock);
      await loadEmis();
    } catch (e) {
      _errorMessage = 'Failed to toggle lock: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process payment
  Future<bool> processPayment({
    required String emiId,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.processPayment(
        emiId: emiId,
        amount: amount,
      );
      await loadEmis();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to process payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh EMI list
  Future<void> refresh() async {
    await loadEmis();
  }
}
