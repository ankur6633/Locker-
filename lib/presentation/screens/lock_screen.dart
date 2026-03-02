import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../viewmodels/locker_view_model.dart';
import '../widgets/loading_widget.dart';

/// Lock screen - shown when EMI is overdue
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    // Back button is disabled via PopScope widget
  }

  Future<void> _handlePayNow() async {
    // Navigate directly to dashboard/home page
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.dashboardRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Consumer<LockerViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.emi == null) {
                return const LoadingWidget();
              }

              if (viewModel.emi == null) {
                return const Center(
                  child: Text('Unable to load EMI details'),
                );
              }

              final emi = viewModel.emi!;
              final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
              final daysOverdue = emi.daysOverdue ?? 0;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 120,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppStrings.deviceLocked,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.emiOverdue,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              AppStrings.dueAmount,
                              currencyFormat.format(emi.emiAmount),
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              AppStrings.nextDueDate,
                              DateFormatter.formatDate(emi.nextDueDate),
                            ),
                            if (daysOverdue > 0) ...[
                              const Divider(),
                              _buildInfoRow(
                                context,
                                AppStrings.daysOverdue,
                                '$daysOverdue days',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppStrings.overdueMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handlePayNow,
                        icon: const Icon(Icons.home_rounded, size: 24),
                        label: Text(
                          AppStrings.payNow,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
