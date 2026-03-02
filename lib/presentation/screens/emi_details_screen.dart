import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/emi.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_strings.dart';

/// EMI Details screen
class EmiDetailsScreen extends StatelessWidget {
  const EmiDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emi = ModalRoute.of(context)!.settings.arguments as Emi;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.emiDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context,
                      AppStrings.totalAmount,
                      currencyFormat.format(emi.totalAmount),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.remainingAmount,
                      currencyFormat.format(emi.remainingAmount),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.emiAmount,
                      currencyFormat.format(emi.emiAmount),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.principalAmount,
                      currencyFormat.format(emi.principalAmount),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.interestAmount,
                      currencyFormat.format(emi.interestAmount),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.emiTenure,
                      '${emi.tenureMonths} months',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.emiStartDate,
                      DateFormatter.formatDate(emi.startDate),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.emiEndDate,
                      DateFormatter.formatDate(emi.endDate),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      AppStrings.nextDueDate,
                      DateFormatter.formatDate(emi.nextDueDate),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
