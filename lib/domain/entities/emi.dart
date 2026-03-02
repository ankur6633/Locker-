import 'package:equatable/equatable.dart';

/// EMI entity
class Emi extends Equatable {
  const Emi({
    required this.id,
    required this.totalAmount,
    required this.emiAmount,
    required this.remainingAmount,
    required this.nextDueDate,
    required this.status,
    required this.principalAmount,
    required this.interestAmount,
    required this.tenureMonths,
    required this.startDate,
    required this.endDate,
    this.daysOverdue,
  });

  final String id;
  final double totalAmount;
  final double emiAmount;
  final double remainingAmount;
  final DateTime nextDueDate;
  final String status; // paid, pending, overdue, upcoming
  final double principalAmount;
  final double interestAmount;
  final int tenureMonths;
  final DateTime startDate;
  final DateTime endDate;
  final int? daysOverdue;

  /// Check if EMI is overdue
  bool get isOverdue => status == 'overdue';

  /// Calculate progress percentage
  double get progressPercentage {
    if (totalAmount == 0) return 0;
    return ((totalAmount - remainingAmount) / totalAmount) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        totalAmount,
        emiAmount,
        remainingAmount,
        nextDueDate,
        status,
        principalAmount,
        interestAmount,
        tenureMonths,
        startDate,
        endDate,
        daysOverdue,
      ];
}
