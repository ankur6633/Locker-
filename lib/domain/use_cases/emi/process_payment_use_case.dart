import '../../entities/payment.dart';
import '../../repositories/emi_repository.dart';
import '../../../core/errors/failures.dart';

/// Process payment use case
class ProcessPaymentUseCase {
  ProcessPaymentUseCase(this._repository);

  final EmiRepository _repository;

  /// Execute process payment
  Future<({Failure? failure, Payment? payment})> call({
    required double amount,
    required String emiId,
  }) async {
    return await _repository.processPayment(amount: amount, emiId: emiId);
  }
}
