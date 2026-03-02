import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/admin_emi_viewmodel.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../models/hive_emi_model.dart';
import '../models/hive_user_model.dart';
import 'admin_create_emi_dialog.dart';

/// Admin EMI Management Screen
class AdminEmiScreen extends StatelessWidget {
  const AdminEmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EMI Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    context.read<AdminEmiViewModel>().refresh();
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer2<AdminEmiViewModel, AdminUsersViewModel>(
              builder: (context, emiViewModel, usersViewModel, child) {
                if (emiViewModel.isLoading && emiViewModel.emis.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (emiViewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(emiViewModel.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => emiViewModel.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Header with Add Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total EMI Records: ${emiViewModel.emis.length}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateEmiDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create EMI'),
                          ),
                        ],
                      ),
                    ),
                    // EMI List
                    Expanded(
                      child: emiViewModel.emis.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: emiViewModel.emis.length,
                              itemBuilder: (context, index) {
                                final emi = emiViewModel.emis[index];
                                HiveUserModel? user;
                                try {
                                  user = usersViewModel.users
                                      .firstWhere((u) => u.id == emi.userId);
                                } catch (e) {
                                  user = null;
                                }
                                return _buildEmiCard(context, emi, user);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No EMI records found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create an EMI record for a user',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateEmiDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create EMI'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiCard(
    BuildContext context,
    HiveEmiModel emi,
    HiveUserModel? user,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = _getStatusColor(emi.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            emi.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: statusColor,
          ),
        ),
        title: Text(
          user?.name ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('EMI Amount: ${currencyFormat.format(emi.emiAmount)}'),
            Text('Remaining: ${currencyFormat.format(emi.remainingAmount)}'),
          ],
        ),
        trailing: Chip(
          label: Text(emi.status.toUpperCase()),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, 'Total Amount', currencyFormat.format(emi.totalAmount)),
                _buildInfoRow(context, 'Principal', currencyFormat.format(emi.principalAmount)),
                _buildInfoRow(context, 'Interest', currencyFormat.format(emi.interestAmount)),
                _buildInfoRow(context, 'Tenure', '${emi.tenureMonths} months'),
                _buildInfoRow(context, 'Interest Rate', '${emi.interestRate}% p.a.'),
                _buildInfoRow(context, 'Start Date', dateFormat.format(emi.startDate)),
                _buildInfoRow(context, 'End Date', dateFormat.format(emi.endDate)),
                _buildInfoRow(context, 'Next Due', dateFormat.format(emi.nextDueDate)),
                if (emi.daysOverdue != null && emi.daysOverdue! > 0)
                  _buildInfoRow(context, 'Days Overdue', '${emi.daysOverdue} days'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _toggleLock(context, emi),
                      icon: Icon(emi.isLocked ? Icons.lock_open_rounded : Icons.lock_rounded),
                      label: Text(emi.isLocked ? 'Unlock' : 'Lock'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: emi.isLocked ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(context, emi),
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text('Process Payment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCreateEmiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdminCreateEmiDialog(),
    );
  }

  void _toggleLock(BuildContext context, HiveEmiModel emi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(emi.isLocked ? 'Unlock Device' : 'Lock Device'),
        content: Text(
          'Are you sure you want to ${emi.isLocked ? 'unlock' : 'lock'} the device for this EMI?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AdminEmiViewModel>().toggleEmiLock(emi.id, !emi.isLocked);
            },
            style: TextButton.styleFrom(
              foregroundColor: emi.isLocked ? Colors.green : Colors.red,
            ),
            child: Text(emi.isLocked ? 'Unlock' : 'Lock'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, HiveEmiModel emi) {
    final amountController = TextEditingController();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remaining Amount: ${currencyFormat.format(emi.remainingAmount)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop();
                final success = await context.read<AdminEmiViewModel>().processPayment(
                      emiId: emi.id,
                      amount: amount,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Payment processed successfully' : 'Failed to process payment',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }
}
