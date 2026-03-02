import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

/// Admin Dashboard Screen
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header with Refresh Button
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
                  'Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    context.read<AdminDashboardViewModel>().refresh();
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer<AdminDashboardViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.stats == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(viewModel.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final stats = viewModel.stats ?? {};
                final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      GridView.count(
                        crossAxisCount: _getCrossAxisCount(context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            context,
                            title: 'Total Users',
                            value: '${stats['totalUsers'] ?? 0}',
                            icon: Icons.people_rounded,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Active Users',
                            value: '${stats['activeUsers'] ?? 0}',
                            icon: Icons.verified_user_rounded,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Total EMI Records',
                            value: '${stats['totalEmis'] ?? 0}',
                            icon: Icons.account_balance_wallet_rounded,
                            color: Colors.purple,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Locked Devices',
                            value: '${stats['lockedEmis'] ?? 0}',
                            icon: Icons.lock_rounded,
                            color: Colors.red,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Overdue EMI',
                            value: '${stats['overdueEmis'] ?? 0}',
                            icon: Icons.warning_rounded,
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Total EMI Amount',
                            value: currencyFormat.format(stats['totalEmiAmount'] ?? 0),
                            icon: Icons.currency_rupee_rounded,
                            color: Colors.teal,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Total Paid',
                            value: currencyFormat.format(stats['totalPaid'] ?? 0),
                            icon: Icons.check_circle_rounded,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Total Remaining',
                            value: currencyFormat.format(stats['totalRemaining'] ?? 0),
                            icon: Icons.pending_rounded,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
