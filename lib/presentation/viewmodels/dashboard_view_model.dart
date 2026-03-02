import 'package:flutter/foundation.dart';
import '../../domain/entities/emi.dart';
import '../../domain/use_cases/emi/get_emi_details_use_case.dart';

/// Dashboard ViewModel
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._getEmiDetailsUseCase);

  final GetEmiDetailsUseCase _getEmiDetailsUseCase;

  bool _isLoading = false;
  Emi? _emi;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Emi? get emi => _emi;
  String? get errorMessage => _errorMessage;

  /// Load EMI details
  Future<void> loadEmiDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getEmiDetailsUseCase();

    _isLoading = false;

    if (result.failure != null) {
      _errorMessage = result.failure!.message;
      notifyListeners();
      return;
    }

    _emi = result.emi;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh EMI details
  Future<void> refresh() async {
    await loadEmiDetails();
  }
}
