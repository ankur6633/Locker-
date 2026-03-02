import 'package:equatable/equatable.dart';

/// EMI Schedule Item entity
class EmiScheduleItem extends Equatable {
  const EmiScheduleItem({
    required this.installmentNumber,
    required this.dueDate,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.status,
    this.paidDate,
  });

  final int installmentNumber;
  final DateTime dueDate;
  final double amount;
  final double principal;
  final double interest;
  final String status; // paid, pending, overdue, upcoming
  final DateTime? paidDate;

  @override
  List<Object?> get props => [
        installmentNumber,
        dueDate,
        amount,
        principal,
        interest,
        status,
        paidDate,
      ];
}
