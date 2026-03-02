import 'package:hive/hive.dart';

/// Hive model for storing EMI data in admin panel
class HiveEmiModel extends HiveObject {
  String id;
  String userId;
  double totalAmount;
  double principalAmount;
  double interestAmount;
  double emiAmount;
  double remainingAmount;
  int tenureMonths;
  double interestRate; // Annual interest rate percentage
  DateTime startDate;
  DateTime endDate;
  DateTime nextDueDate;
  String status; // paid, pending, overdue, upcoming
  int? daysOverdue;
  bool isLocked;
  DateTime createdAt;

  HiveEmiModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.principalAmount,
    required this.interestAmount,
    required this.emiAmount,
    required this.remainingAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.startDate,
    required this.endDate,
    required this.nextDueDate,
    required this.status,
    this.daysOverdue,
    this.isLocked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'totalAmount': totalAmount,
        'principalAmount': principalAmount,
        'interestAmount': interestAmount,
        'emiAmount': emiAmount,
        'remainingAmount': remainingAmount,
        'tenureMonths': tenureMonths,
        'interestRate': interestRate,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'nextDueDate': nextDueDate.toIso8601String(),
        'status': status,
        'daysOverdue': daysOverdue,
        'isLocked': isLocked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HiveEmiModel.fromJson(Map<String, dynamic> json) => HiveEmiModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        principalAmount: (json['principalAmount'] as num).toDouble(),
        interestAmount: (json['interestAmount'] as num).toDouble(),
        emiAmount: (json['emiAmount'] as num).toDouble(),
        remainingAmount: (json['remainingAmount'] as num).toDouble(),
        tenureMonths: json['tenureMonths'] as int,
        interestRate: (json['interestRate'] as num).toDouble(),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        nextDueDate: DateTime.parse(json['nextDueDate'] as String),
        status: json['status'] as String,
        daysOverdue: json['daysOverdue'] as int?,
        isLocked: json['isLocked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
