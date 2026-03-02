import '../../domain/entities/payment.dart';

/// Payment model extending Payment entity
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.date,
    required super.status,
    required super.emiId,
    super.transactionId,
    super.paymentMethod,
    super.notes,
  });

  /// Create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      emiId: json['emiId'] as String,
      transactionId: json['transactionId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert PaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'emiId': emiId,
      if (transactionId != null) 'transactionId': transactionId,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
    };
  }
}
