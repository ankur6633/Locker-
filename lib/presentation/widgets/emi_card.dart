import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/emi.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_strings.dart';
import 'animated_progress_bar.dart';

/// EMI Card widget for dashboard
class EmiCard extends StatelessWidget {
  const EmiCard({
    super.key,
    required this.emi,
    this.onTap,
  });

  final Emi emi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.emiStatus,
                    style: theme.textTheme.bodyMedium,
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 24),
              _buildAmountRow(
                context,
                AppStrings.totalAmount,
                currencyFormat.format(emi.totalAmount),
                theme.textTheme.titleLarge!,
              ),
              const SizedBox(height: 16),
              _buildAmountRow(
                context,
                AppStrings.remainingAmount,
                currencyFormat.format(emi.remainingAmount),
                theme.textTheme.headlineMedium!,
              ),
              const SizedBox(height: 24),
              AnimatedProgressBar(
                progress: emi.progressPercentage,
                height: 12,
              ),
              const SizedBox(height: 8),
              Text(
                '${emi.progressPercentage.toStringAsFixed(1)}% ${AppStrings.paid.toLowerCase()}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    context,
                    AppStrings.emiAmount,
                    currencyFormat.format(emi.emiAmount),
                  ),
                  _buildInfoColumn(
                    context,
                    AppStrings.nextDueDate,
                    DateFormatter.formatDate(emi.nextDueDate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (emi.status) {
      case 'overdue':
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        statusText = 'Overdue';
        break;
      case 'paid':
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        statusText = 'Paid';
        break;
      case 'pending':
        backgroundColor = Colors.amber.withValues(alpha: 0.2);
        textColor = Colors.amber.shade700;
        statusText = 'Pending';
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
        statusText = 'Upcoming';
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    String amount,
    TextStyle style,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          amount,
          style: style.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
