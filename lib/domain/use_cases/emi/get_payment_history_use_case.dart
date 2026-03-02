import '../../entities/payment.dart';
import '../../repositories/emi_repository.dart';
import '../../../core/errors/failures.dart';

/// Get payment history use case
class GetPaymentHistoryUseCase {
  GetPaymentHistoryUseCase(this._repository);

  final EmiRepository _repository;

  /// Execute get payment history
  Future<({Failure? failure, List<Payment>? payments})> call() async {
    return await _repository.getPaymentHistory();
  }
}
