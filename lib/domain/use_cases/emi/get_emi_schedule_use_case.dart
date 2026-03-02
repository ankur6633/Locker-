import '../../entities/emi_schedule_item.dart';
import '../../repositories/emi_repository.dart';
import '../../../core/errors/failures.dart';

/// Get EMI schedule use case
class GetEmiScheduleUseCase {
  GetEmiScheduleUseCase(this._repository);

  final EmiRepository _repository;

  /// Execute get EMI schedule
  Future<({Failure? failure, List<EmiScheduleItem>? schedule})> call() async {
    return await _repository.getEmiSchedule();
  }
}
