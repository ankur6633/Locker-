import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/emi_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widget;

/// Dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadEmiDetails();
    });
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(AppConstants.userRoleKey);
    setState(() {
      _userRole = role;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.logout();
      
      // Clear user role and login email/mobile
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userRoleKey);
      await prefs.remove(AppConstants.loginEmailOrMobileKey);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.dashboard_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.dashboard),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.emi == null) {
            return const LoadingWidget();
          }

          if (viewModel.errorMessage != null && viewModel.emi == null) {
            return error_widget.ErrorDisplayWidget(
              message: viewModel.errorMessage!,
              onRetry: () => viewModel.refresh(),
            );
          }

          if (viewModel.emi == null) {
            return const Center(
              child: Text('No EMI data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // EMI Overview Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: EmiCard(
                      emi: viewModel.emi!,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppConstants.emiDetailsRoute,
                          arguments: viewModel.emi!,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quick Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernActionButton(
                                context,
                                icon: Icons.payment_rounded,
                                label: AppStrings.paymentHistory,
                                color: Colors.green,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppConstants.paymentHistoryRoute,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernActionButton(
                                context,
                                icon: Icons.calendar_today_rounded,
                                label: AppStrings.emiSchedule,
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppConstants.emiScheduleRoute,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionButton(
                          context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: AppStrings.createMandate,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppConstants.createMandateRoute,
                            );
                          },
                          fullWidth: true,
                        ),
                        // Only show Admin Panel button if user is admin
                        if (_userRole == 'admin') ...[
                          const SizedBox(height: 12),
                          _buildModernActionButton(
                            context,
                            icon: Icons.admin_panel_settings_rounded,
                            label: AppStrings.adminPanel,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppConstants.adminPanelRoute,
                              );
                            },
                            fullWidth: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build Modern Action Button
  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    Widget buttonContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: fullWidth
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: buttonContent) : buttonContent;
  }
}
