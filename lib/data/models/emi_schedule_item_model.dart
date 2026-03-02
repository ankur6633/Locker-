import '../../domain/entities/emi_schedule_item.dart';

/// EMI Schedule Item model extending EmiScheduleItem entity
class EmiScheduleItemModel extends EmiScheduleItem {
  const EmiScheduleItemModel({
    required super.installmentNumber,
    required super.dueDate,
    required super.amount,
    required super.principal,
    required super.interest,
    required super.status,
    super.paidDate,
  });

  /// Create EmiScheduleItemModel from JSON
  factory EmiScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return EmiScheduleItemModel(
      installmentNumber: json['installmentNumber'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      principal: (json['principal'] as num).toDouble(),
      interest: (json['interest'] as num).toDouble(),
      status: json['status'] as String,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
    );
  }

  /// Convert EmiScheduleItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'installmentNumber': installmentNumber,
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'principal': principal,
      'interest': interest,
      'status': status,
      if (paidDate != null) 'paidDate': paidDate!.toIso8601String(),
    };
  }
}
