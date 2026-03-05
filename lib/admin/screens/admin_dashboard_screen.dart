import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
    NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(context, viewModel);
          }

          final stats = viewModel.stats ?? {};

          final items = [
            _StatItem("Total Users",
                "${stats['totalUsers'] ?? 0}", Icons.people_rounded, Colors.blue),
            _StatItem("Active Users",
                "${stats['activeUsers'] ?? 0}", Icons.verified_user_rounded, Colors.green),
            _StatItem("Total EMI Records",
                "${stats['totalEmis'] ?? 0}", Icons.account_balance_wallet_rounded, Colors.purple),
            _StatItem("Locked Devices",
                "${stats['lockedEmis'] ?? 0}", Icons.lock_rounded, Colors.red),
            _StatItem("Overdue EMI",
                "${stats['overdueEmis'] ?? 0}", Icons.warning_rounded, Colors.orange),
            _StatItem("Total EMI Amount",
                currencyFormat.format(stats['totalEmiAmount'] ?? 0),
                Icons.currency_rupee_rounded, Colors.teal),
            _StatItem("Total Paid",
                currencyFormat.format(stats['totalPaid'] ?? 0),
                Icons.check_circle_rounded, Colors.green),
            _StatItem("Total Remaining",
                currencyFormat.format(stats['totalRemaining'] ?? 0),
                Icons.pending_rounded, Colors.amber),
          ];

          return Column(
            children: [
              _buildHeader(context, viewModel),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.7,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildPremiumStatCard(context, item);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AdminDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Dashboard Overview",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: () => viewModel.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, AdminDashboardViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(viewModel.errorMessage ?? "Something went wrong"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.refresh(),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumStatCard(
      BuildContext context, _StatItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.color.withOpacity(0.18),
            item.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon,
                      color: item.color, size: 20),
                ),
              ],
            ),
            const Spacer(), // 🔥 Prevent overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.title, this.value, this.icon, this.color);
}