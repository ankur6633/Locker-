import 'package:equatable/equatable.dart';

/// Mandate entity for auto-debit authorization
class Mandate extends Equatable {
  const Mandate({
    required this.id,
    required this.mandateId,
    required this.amount,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentMethod,
    this.bankAccountNumber,
    this.ifscCode,
    this.upiId,
    this.cardLast4,
    this.cardType,
    this.maxAmount,
    this.createdAt,
    this.updatedAt,
    this.nextDebitDate,
    this.debitCount,
    this.maxDebits,
  });

  final String id;
  final String mandateId; // External mandate ID (e.g., UPI mandate ID)
  final double amount; // Amount to be debited per cycle
  final String frequency; // daily, weekly, monthly, quarterly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, paused, cancelled, expired, pending
  final String paymentMethod; // upi, bank_account, card, wallet
  
  // Bank Account Details
  final String? bankAccountNumber;
  final String? ifscCode;
  
  // UPI Details
  final String? upiId;
  
  // Card Details
  final String? cardLast4;
  final String? cardType; // credit, debit
  
  // Mandate Limits
  final double? maxAmount; // Maximum amount per debit
  final int? maxDebits; // Maximum number of debits allowed
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? nextDebitDate;
  final int? debitCount; // Number of debits executed

  /// Check if mandate is active
  bool get isActive => status == 'active';

  /// Check if mandate is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if mandate can be used
  bool get canUse => isActive && !isExpired && (maxDebits == null || (debitCount ?? 0) < maxDebits!);

  @override
  List<Object?> get props => [
        id,
        mandateId,
        amount,
        frequency,
        startDate,
        endDate,
        status,
        paymentMethod,
        bankAccountNumber,
        ifscCode,
        upiId,
        cardLast4,
        cardType,
        maxAmount,
        createdAt,
        updatedAt,
        nextDebitDate,
        debitCount,
        maxDebits,
      ];
}
