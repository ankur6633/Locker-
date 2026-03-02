import 'package:equatable/equatable.dart';

/// Payment entity
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.emiId,
    this.transactionId,
    this.paymentMethod,
    this.notes,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String status; // success, pending, failed
  final String emiId;
  final String? transactionId;
  final String? paymentMethod;
  final String? notes;

  @override
  List<Object?> get props => [
        id,
        amount,
        date,
        status,
        emiId,
        transactionId,
        paymentMethod,
        notes,
      ];
}
