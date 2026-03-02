import '../../domain/entities/emi.dart';

/// EMI model extending EMI entity
class EmiModel extends Emi {
  const EmiModel({
    required super.id,
    required super.totalAmount,
    required super.emiAmount,
    required super.remainingAmount,
    required super.nextDueDate,
    required super.status,
    required super.principalAmount,
    required super.interestAmount,
    required super.tenureMonths,
    required super.startDate,
    required super.endDate,
    super.daysOverdue,
  });

  /// Create EmiModel from JSON
  factory EmiModel.fromJson(Map<String, dynamic> json) {
    return EmiModel(
      id: json['id'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      emiAmount: (json['emiAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      status: json['status'] as String,
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestAmount: (json['interestAmount'] as num).toDouble(),
      tenureMonths: json['tenureMonths'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      daysOverdue: json['daysOverdue'] as int?,
    );
  }

  /// Convert EmiModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'emiAmount': emiAmount,
      'remainingAmount': remainingAmount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'status': status,
      'principalAmount': principalAmount,
      'interestAmount': interestAmount,
      'tenureMonths': tenureMonths,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (daysOverdue != null) 'daysOverdue': daysOverdue,
    };
  }
}
