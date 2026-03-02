import '../../domain/entities/mandate.dart';

/// Mandate data model
class MandateModel extends Mandate {
  const MandateModel({
    required super.id,
    required super.mandateId,
    required super.amount,
    required super.frequency,
    required super.startDate,
    required super.endDate,
    required super.status,
    required super.paymentMethod,
    super.bankAccountNumber,
    super.ifscCode,
    super.upiId,
    super.cardLast4,
    super.cardType,
    super.maxAmount,
    super.createdAt,
    super.updatedAt,
    super.nextDebitDate,
    super.debitCount,
    super.maxDebits,
  });

  factory MandateModel.fromJson(Map<String, dynamic> json) {
    return MandateModel(
      id: json['id'] as String,
      mandateId: json['mandateId'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      upiId: json['upiId'] as String?,
      cardLast4: json['cardLast4'] as String?,
      cardType: json['cardType'] as String?,
      maxAmount: json['maxAmount'] != null ? (json['maxAmount'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      nextDebitDate: json['nextDebitDate'] != null ? DateTime.parse(json['nextDebitDate'] as String) : null,
      debitCount: json['debitCount'] as int?,
      maxDebits: json['maxDebits'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mandateId': mandateId,
      'amount': amount,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'upiId': upiId,
      'cardLast4': cardLast4,
      'cardType': cardType,
      'maxAmount': maxAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'nextDebitDate': nextDebitDate?.toIso8601String(),
      'debitCount': debitCount,
      'maxDebits': maxDebits,
    };
  }
}
