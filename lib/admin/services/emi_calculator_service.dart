import 'dart:math';

/// Service for calculating EMI and related financial calculations
class EmiCalculatorService {
  /// Calculate EMI amount using the formula:
  /// EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]
  /// Where:
  /// P = Principal amount
  /// R = Monthly interest rate (Annual rate / 12 / 100)
  /// N = Number of months
  static double calculateEmi({
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    if (tenureMonths <= 0 || principalAmount <= 0) {
      return 0;
    }

    final monthlyRate = annualInterestRate / 12 / 100;
    
    if (monthlyRate == 0) {
      // If no interest, EMI is just principal divided by tenure
      return principalAmount / tenureMonths;
    }

    final emi = (principalAmount *
            monthlyRate *
            pow(1 + monthlyRate, tenureMonths)) /
        (pow(1 + monthlyRate, tenureMonths) - 1);

    return emi;
  }

  /// Calculate total interest amount
  static double calculateTotalInterest({
    required double principalAmount,
    required double emiAmount,
    required int tenureMonths,
  }) {
    final totalAmount = emiAmount * tenureMonths;
    return totalAmount - principalAmount;
  }

  /// Calculate total amount (Principal + Interest)
  static double calculateTotalAmount({
    required double principalAmount,
    required double emiAmount,
    required int tenureMonths,
  }) {
    return emiAmount * tenureMonths;
  }

  /// Calculate remaining amount after some payments
  static double calculateRemainingAmount({
    required double totalAmount,
    required double paidAmount,
  }) {
    return (totalAmount - paidAmount).clamp(0, totalAmount);
  }

  /// Generate EMI schedule
  static List<EmiScheduleItem> generateSchedule({
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime startDate,
  }) {
    final emiAmount = calculateEmi(
      principalAmount: principalAmount,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );

    final monthlyRate = annualInterestRate / 12 / 100;
    double remainingPrincipal = principalAmount;
    final schedule = <EmiScheduleItem>[];

    for (int i = 0; i < tenureMonths; i++) {
      final dueDate = DateTime(
        startDate.year,
        startDate.month + i,
        startDate.day,
      );

      final interestComponent = remainingPrincipal * monthlyRate;
      final principalComponent = emiAmount - interestComponent;
      remainingPrincipal -= principalComponent;

      schedule.add(EmiScheduleItem(
        installmentNumber: i + 1,
        dueDate: dueDate,
        emiAmount: emiAmount,
        principalComponent: principalComponent,
        interestComponent: interestComponent,
        remainingPrincipal: remainingPrincipal.clamp(0, double.infinity),
        status: 'upcoming',
      ));
    }

    return schedule;
  }
}

/// EMI Schedule Item
class EmiScheduleItem {
  final int installmentNumber;
  final DateTime dueDate;
  final double emiAmount;
  final double principalComponent;
  final double interestComponent;
  final double remainingPrincipal;
  final String status; // paid, pending, overdue, upcoming

  EmiScheduleItem({
    required this.installmentNumber,
    required this.dueDate,
    required this.emiAmount,
    required this.principalComponent,
    required this.interestComponent,
    required this.remainingPrincipal,
    required this.status,
  });
}
