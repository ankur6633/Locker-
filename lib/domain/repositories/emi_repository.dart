import '../entities/emi.dart';
import '../entities/payment.dart';
import '../entities/emi_schedule_item.dart';
import '../../core/errors/failures.dart';

/// EMI repository interface
abstract class EmiRepository {
  /// Get EMI details
  Future<({Failure? failure, Emi? emi})> getEmiDetails();

  /// Get payment history
  Future<({Failure? failure, List<Payment>? payments})> getPaymentHistory();

  /// Get EMI schedule
  Future<({Failure? failure, List<EmiScheduleItem>? schedule})> getEmiSchedule();

  /// Process payment
  Future<({Failure? failure, Payment? payment})> processPayment({
    required double amount,
    required String emiId,
  });

  /// Check EMI status (for locker engine)
  Future<({Failure? failure, bool? isOverdue})> checkEmiStatus();
}
