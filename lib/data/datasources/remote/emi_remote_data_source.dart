import '../../models/emi_model.dart';
import '../../models/payment_model.dart';
import '../../models/emi_schedule_item_model.dart';
import 'api_client.dart';

/// Remote data source for EMI
abstract class EmiRemoteDataSource {
  Future<({Exception? exception, EmiModel? emi})> getEmiDetails();
  Future<({Exception? exception, List<PaymentModel>? payments})> getPaymentHistory();
  Future<({Exception? exception, List<EmiScheduleItemModel>? schedule})> getEmiSchedule();
  Future<({Exception? exception, PaymentModel? payment})> processPayment({
    required double amount,
    required String emiId,
  });
}

/// Implementation of EmiRemoteDataSource
class EmiRemoteDataSourceImpl implements EmiRemoteDataSource {
  EmiRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({Exception? exception, EmiModel? emi})> getEmiDetails() async {
    try {
      final response = await _apiClient.get('/emi/details');
      final emi = EmiModel.fromJson(response.data as Map<String, dynamic>);
      return (exception: null, emi: emi);
    } on Exception catch (e) {
      return (exception: e, emi: null);
    }
  }

  @override
  Future<({Exception? exception, List<PaymentModel>? payments})> getPaymentHistory() async {
    try {
      final response = await _apiClient.get('/emi/payments');
      final payments = (response.data as List)
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return (exception: null, payments: payments);
    } on Exception catch (e) {
      return (exception: e, payments: null);
    }
  }

  @override
  Future<({Exception? exception, List<EmiScheduleItemModel>? schedule})> getEmiSchedule() async {
    try {
      final response = await _apiClient.get('/emi/schedule');
      final schedule = (response.data as List)
          .map((json) => EmiScheduleItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return (exception: null, schedule: schedule);
    } on Exception catch (e) {
      return (exception: e, schedule: null);
    }
  }

  @override
  Future<({Exception? exception, PaymentModel? payment})> processPayment({
    required double amount,
    required String emiId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/emi/payment',
        data: {
          'amount': amount,
          'emiId': emiId,
        },
      );
      final payment = PaymentModel.fromJson(response.data as Map<String, dynamic>);
      return (exception: null, payment: payment);
    } on Exception catch (e) {
      return (exception: e, payment: null);
    }
  }
}

/// Mock implementation for development/testing
class EmiRemoteDataSourceMock implements EmiRemoteDataSource {
  @override
  Future<({Exception? exception, EmiModel? emi})> getEmiDetails() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock EMI data - simulate overdue scenario
    final now = DateTime.now();
    final nextDueDate = now.subtract(const Duration(days: 5)); // Overdue by 5 days

    final emi = EmiModel(
      id: 'emi_1',
      totalAmount: 100000.0,
      emiAmount: 10000.0,
      remainingAmount: 60000.0,
      nextDueDate: nextDueDate,
      status: 'overdue',
      principalAmount: 80000.0,
      interestAmount: 20000.0,
      tenureMonths: 10,
      startDate: now.subtract(const Duration(days: 120)),
      endDate: now.add(const Duration(days: 180)),
      daysOverdue: 5,
    );

    return (exception: null, emi: emi);
  }

  @override
  Future<({Exception? exception, List<PaymentModel>? payments})> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final payments = List.generate(
      4,
      (index) => PaymentModel(
        id: 'payment_$index',
        amount: 10000.0,
        date: DateTime.now().subtract(Duration(days: (index + 1) * 30)),
        status: 'success',
        emiId: 'emi_1',
        transactionId: 'txn_$index',
        paymentMethod: 'UPI',
      ),
    );

    return (exception: null, payments: payments);
  }

  @override
  Future<({Exception? exception, List<EmiScheduleItemModel>? schedule})> getEmiSchedule() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final schedule = List.generate(
      10,
      (index) {
        final dueDate = now.add(Duration(days: index * 30));
        final isPast = dueDate.isBefore(now);
        final isOverdue = isPast && index < 5;

        return EmiScheduleItemModel(
          installmentNumber: index + 1,
          dueDate: dueDate,
          amount: 10000.0,
          principal: 8000.0,
          interest: 2000.0,
          status: isOverdue
              ? 'overdue'
              : isPast
                  ? 'paid'
                  : index == 5
                      ? 'pending'
                      : 'upcoming',
          paidDate: isPast && !isOverdue ? dueDate.add(const Duration(days: 2)) : null,
        );
      },
    );

    return (exception: null, schedule: schedule);
  }

  @override
  Future<({Exception? exception, PaymentModel? payment})> processPayment({
    required double amount,
    required String emiId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final payment = PaymentModel(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      status: 'success',
      emiId: emiId,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: 'UPI',
    );

    return (exception: null, payment: payment);
  }
}
