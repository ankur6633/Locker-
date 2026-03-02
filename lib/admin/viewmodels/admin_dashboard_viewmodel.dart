import 'package:flutter/foundation.dart';
import '../services/admin_data_service.dart';

/// ViewModel for Admin Dashboard
class AdminDashboardViewModel extends ChangeNotifier {
  final AdminDataService _dataService;

  AdminDashboardViewModel(this._dataService);

  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load dashboard statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
      _stats = _dataService.getDashboardStats();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load statistics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStats();
  }
}
