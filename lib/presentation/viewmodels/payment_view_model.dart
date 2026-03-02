import 'package:flutter/foundation.dart';
import '../../domain/entities/payment.dart';
import '../../domain/use_cases/emi/process_payment_use_case.dart';

/// Payment ViewModel
class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel(this._processPaymentUseCase);

  final ProcessPaymentUseCase _processPaymentUseCase;

  bool _isLoading = false;
  Payment? _payment;
  String? _errorMessage;
  bool _isPaymentSuccess = false;

  bool get isLoading => _isLoading;
  Payment? get payment => _payment;
  String? get errorMessage => _errorMessage;
  bool get isPaymentSuccess => _isPaymentSuccess;

  /// Process payment
  Future<bool> processPayment({
    required double amount,
    required String emiId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isPaymentSuccess = false;
    notifyListeners();

    final result = await _processPaymentUseCase(
      amount: amount,
      emiId: emiId,
    );

    _isLoading = false;

    if (result.failure != null) {
      _errorMessage = result.failure!.message;
      notifyListeners();
      return false;
    }

    if (result.payment != null) {
      _payment = result.payment;
      _isPaymentSuccess = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Payment failed';
    notifyListeners();
    return false;
  }

  /// Reset payment state
  void reset() {
    _payment = null;
    _isPaymentSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}
