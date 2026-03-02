import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/admin_emi_viewmodel.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../models/hive_emi_model.dart';
import '../models/hive_user_model.dart';

/// Admin Lock Control Screen
class AdminLockControlScreen extends StatelessWidget {
  const AdminLockControlScreen({super.key});

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
                  'Lock Control',
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
                final lockedEmis = emiViewModel.emis.where((e) => e.isLocked).toList();
                final unlockedEmis = emiViewModel.emis.where((e) => !e.isLocked).toList();

                return Row(
                  children: [
                    // Locked Devices Section
                    Expanded(
                      child: _buildSection(
                        context,
                        title: 'Locked Devices',
                        emis: lockedEmis,
                        usersViewModel: usersViewModel,
                        emiViewModel: emiViewModel,
                        emptyMessage: 'No devices are currently locked',
                        emptyIcon: Icons.lock_open_rounded,
                        isLocked: true,
                      ),
                    ),
                    // Divider
                    Container(
                      width: 1,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    // Unlocked Devices Section
                    Expanded(
                      child: _buildSection(
                        context,
                        title: 'Unlocked Devices',
                        emis: unlockedEmis,
                        usersViewModel: usersViewModel,
                        emiViewModel: emiViewModel,
                        emptyMessage: 'No devices are currently unlocked',
                        emptyIcon: Icons.lock_rounded,
                        isLocked: false,
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<HiveEmiModel> emis,
    required AdminUsersViewModel usersViewModel,
    required AdminEmiViewModel emiViewModel,
    required String emptyMessage,
    required IconData emptyIcon,
    required bool isLocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: isLocked ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                '$title (${emis.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: emis.isEmpty
              ? _buildEmptyState(context, emptyMessage, emptyIcon)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: emis.length,
                  itemBuilder: (context, index) {
                    final emi = emis[index];
                    HiveUserModel? user;
                    try {
                      user = usersViewModel.users
                          .firstWhere((u) => u.id == emi.userId);
                    } catch (e) {
                      user = null;
                    }
                    return _buildDeviceCard(context, emi, user, emiViewModel, isLocked);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    HiveEmiModel emi,
    HiveUserModel? user,
    AdminEmiViewModel emiViewModel,
    bool isLocked,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isLocked
          ? Colors.red.withValues(alpha: 0.05)
          : Colors.green.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
          child: Icon(
            isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: isLocked ? Colors.red : Colors.green,
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
            Text('Email: ${user?.email ?? 'N/A'}'),
            Text('EMI Amount: ${currencyFormat.format(emi.emiAmount)}'),
            Text('Remaining: ${currencyFormat.format(emi.remainingAmount)}'),
            if (emi.daysOverdue != null && emi.daysOverdue! > 0)
              Text(
                'Days Overdue: ${emi.daysOverdue}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            Text('Next Due: ${dateFormat.format(emi.nextDueDate)}'),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _toggleLock(context, emi, emiViewModel, isLocked),
          icon: Icon(isLocked ? Icons.lock_open_rounded : Icons.lock_rounded),
          label: Text(isLocked ? 'Unlock' : 'Lock'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLocked ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _toggleLock(
    BuildContext context,
    HiveEmiModel emi,
    AdminEmiViewModel emiViewModel,
    bool currentLockStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentLockStatus ? 'Unlock Device' : 'Lock Device'),
        content: Text(
          'Are you sure you want to ${currentLockStatus ? 'unlock' : 'lock'} the device for this EMI?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              emiViewModel.toggleEmiLock(emi.id, !currentLockStatus);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device ${currentLockStatus ? 'unlocked' : 'locked'} successfully',
                  ),
                  backgroundColor: currentLockStatus ? Colors.green : Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: currentLockStatus ? Colors.green : Colors.red,
            ),
            child: Text(currentLockStatus ? 'Unlock' : 'Lock'),
          ),
        ],
      ),
    );
  }
}
