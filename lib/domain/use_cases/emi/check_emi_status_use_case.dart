import '../../repositories/emi_repository.dart';
import '../../../core/errors/failures.dart';

/// Check EMI status use case (for locker engine)
class CheckEmiStatusUseCase {
  CheckEmiStatusUseCase(this._repository);

  final EmiRepository _repository;

  /// Execute check EMI status
  Future<({Failure? failure, bool? isOverdue})> call() async {
    return await _repository.checkEmiStatus();
  }
}
