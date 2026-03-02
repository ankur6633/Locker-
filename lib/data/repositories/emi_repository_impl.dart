import '../../domain/entities/emi.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/emi_schedule_item.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/emi_remote_data_source.dart';
import '../datasources/local/local_storage.dart';
import '../../core/constants/app_constants.dart';

/// Implementation of EmiRepository
class EmiRepositoryImpl implements EmiRepository {
  EmiRepositoryImpl(this._remoteDataSource, this._localStorage);

  final EmiRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  @override
  Future<({Failure? failure, Emi? emi})> getEmiDetails() async {
    try {
      final result = await _remoteDataSource.getEmiDetails();

      if (result.exception != null) {
        return (
          failure: _mapExceptionToFailure(result.exception!),
          emi: null,
        );
      }

      if (result.emi != null) {
        // Cache EMI status locally for locker engine
        await _localStorage.saveString(
          AppConstants.emiStatusKey,
          result.emi!.status,
        );

        return (failure: null, emi: result.emi!);
      }

      return (failure: const ServerFailure('Failed to get EMI details'), emi: null);
    } catch (e) {
      return (
        failure: const NetworkFailure('Network error occurred'),
        emi: null,
      );
    }
  }

  @override
  Future<({Failure? failure, List<Payment>? payments})> getPaymentHistory() async {
    try {
      final result = await _remoteDataSource.getPaymentHistory();

      if (result.exception != null) {
        return (
          failure: _mapExceptionToFailure(result.exception!),
          payments: null,
        );
      }

      return (failure: null, payments: result.payments);
    } catch (e) {
      return (
        failure: const NetworkFailure('Network error occurred'),
        payments: null,
      );
    }
  }

  @override
  Future<({Failure? failure, List<EmiScheduleItem>? schedule})> getEmiSchedule() async {
    try {
      final result = await _remoteDataSource.getEmiSchedule();

      if (result.exception != null) {
        return (
          failure: _mapExceptionToFailure(result.exception!),
          schedule: null,
        );
      }

      return (failure: null, schedule: result.schedule);
    } catch (e) {
      return (
        failure: const NetworkFailure('Network error occurred'),
        schedule: null,
      );
    }
  }

  @override
  Future<({Failure? failure, Payment? payment})> processPayment({
    required double amount,
    required String emiId,
  }) async {
    try {
      final result = await _remoteDataSource.processPayment(
        amount: amount,
        emiId: emiId,
      );

      if (result.exception != null) {
        return (
          failure: _mapExceptionToFailure(result.exception!),
          payment: null,
        );
      }

      return (failure: null, payment: result.payment);
    } catch (e) {
      return (
        failure: const NetworkFailure('Network error occurred'),
        payment: null,
      );
    }
  }

  @override
  Future<({Failure? failure, bool? isOverdue})> checkEmiStatus() async {
    try {
      // First check cached status
      final cachedStatus = await _localStorage.getString(AppConstants.emiStatusKey);
      if (cachedStatus == AppConstants.emiStatusOverdue) {
        return (failure: null, isOverdue: true);
      }

      // Fetch latest status from API
      final result = await getEmiDetails();
      if (result.failure != null) {
        return (failure: result.failure, isOverdue: null);
      }

      final isOverdue = result.emi?.isOverdue ?? false;
      return (failure: null, isOverdue: isOverdue);
    } catch (e) {
      return (
        failure: const NetworkFailure('Failed to check EMI status'),
        isOverdue: null,
      );
    }
  }

  Failure _mapExceptionToFailure(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return NetworkFailure('An error occurred');
  }
}
