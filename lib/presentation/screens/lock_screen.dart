import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../../admin/services/admin_data_service.dart';
import '../viewmodels/locker_view_model.dart';
import '../widgets/loading_widget.dart';

/// Lock screen - shown when EMI is overdue or device locked by admin
class LockScreen extends StatefulWidget {
  final bool isLockedByAdmin;
  
  const LockScreen({super.key, this.isLockedByAdmin = false});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _showScanner = false;
  final TextEditingController _unlockCodeController = TextEditingController();
  final AdminDataService _adminDataService = AdminDataService();
  final DeviceControlRepository _deviceControlRepo = sl<DeviceControlRepository>();

  @override
  void initState() {
    super.initState();
    _initializeAdminService();
    // Show scanner by default when user logs in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showScanner = true;
      });
    });
    // Back button is disabled via PopScope widget
  }

  Future<void> _initializeAdminService() async {
    try {
      await _adminDataService.init();
    } catch (e) {
      // Already initialized, continue
    }
  }

  @override
  void dispose() {
    _unlockCodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePayNow() async {
    // Show scanner
    setState(() {
      _showScanner = true;
    });
  }

  Future<void> _handleOkPressed() async {
    // Unlock device when OK is pressed
    await _unlockDevice();
  }

  Future<void> _unlockDevice() async {
    // Get login email or mobile from stored preferences
    final prefs = await SharedPreferences.getInstance();
    final loginEmailOrMobile = prefs.getString(AppConstants.loginEmailOrMobileKey);
    
    // Also try to get from auth repository
    final authRepo = sl<AuthRepository>();
    final userResult = await authRepo.getCurrentUser();
    final userEmail = userResult.user?.email;
    final userMobile = userResult.user?.phoneNumber;

    final emailOrMobile = loginEmailOrMobile ?? userEmail ?? userMobile;

    if (emailOrMobile != null) {
      try {
        // Unlock device in admin service (by email OR mobile)
        await _adminDataService.lockDeviceByEmailOrMobile(emailOrMobile, false);
        
        // Disable kiosk mode
        await _deviceControlRepo.disableKioskMode();
        await _deviceControlRepo.allowScreenshot();

        if (mounted) {
          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed(AppConstants.dashboardRoute);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to unlock device: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show scanner view directly if scanner is enabled
    if (_showScanner) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: _buildScannerView(context),
          ),
        ),
      );
    }

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
                // If no EMI data, show scanner directly
                return _buildScannerView(context);
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
                      widget.isLockedByAdmin
                          ? 'Device locked by admin'
                          : AppStrings.emiOverdue,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (!widget.isLockedByAdmin) ...[
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
                    ],
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handlePayNow,
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
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

  Widget _buildScannerView(BuildContext context) {
    return Column(
      children: [
        // Scanner Image (Default Network Image)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://via.placeholder.com/400x400/000000/FFFFFF?text=QR+Scanner',
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if network image fails - show icon instead
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 120,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'QR Scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // TextField and OK Button
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _unlockCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter unlock code',
                  hintText: 'Enter code to unlock device',
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleOkPressed,
                  icon: const Icon(Icons.check_circle_rounded, size: 24),
                  label: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
