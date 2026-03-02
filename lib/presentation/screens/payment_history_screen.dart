import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../domain/use_cases/emi/get_payment_history_use_case.dart';
import '../../core/utils/date_formatter.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widget;

/// Payment History screen
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  bool _isLoading = true;
  List<Payment>? _payments;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = GetPaymentHistoryUseCase(sl<EmiRepository>());
    final result = await useCase.call();

    setState(() {
      _isLoading = false;
      if (result.failure != null) {
        _errorMessage = result.failure!.message;
      } else {
        _payments = result.payments ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.paymentHistory),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _errorMessage != null
              ? error_widget.ErrorDisplayWidget(
                  message: _errorMessage!,
                  onRetry: _loadPaymentHistory,
                )
              : _payments == null || _payments!.isEmpty
                  ? Center(
                      child: Text(
                        'No payment history available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPaymentHistory,
                      child: ListView.builder(
                        itemCount: _payments!.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final payment = _payments![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: payment.status == 'success'
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.errorContainer,
                                child: Icon(
                                  payment.status == 'success'
                                      ? Icons.check
                                      : Icons.error,
                                  color: payment.status == 'success'
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              title: Text(
                                currencyFormat.format(payment.amount),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.formatDate(payment.date),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (payment.transactionId != null)
                                    Text(
                                      'Txn: ${payment.transactionId}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  payment.status.toUpperCase(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: payment.status == 'success'
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.errorContainer,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
