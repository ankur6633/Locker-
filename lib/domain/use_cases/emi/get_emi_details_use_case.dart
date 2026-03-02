import '../../entities/emi.dart';
import '../../repositories/emi_repository.dart';
import '../../../core/errors/failures.dart';

/// Get EMI details use case
class GetEmiDetailsUseCase {
  GetEmiDetailsUseCase(this._repository);

  final EmiRepository _repository;

  /// Execute get EMI details
  Future<({Failure? failure, Emi? emi})> call() async {
    return await _repository.getEmiDetails();
  }
}
