import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../../domain/entities/device_feature.dart';
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
  final DeviceControlRepository _deviceControlRepo = sl<DeviceControlRepository>();
  bool? _isRooted;
  bool _isCheckingRoot = false;

  // Device Features List
  late List<DeviceFeature> _deviceFeatures;
  
  // App Control List
  late List<AppControl> _apps;

  @override
  void initState() {
    super.initState();
    _initializeDeviceFeatures();
    _initializeApps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadEmiDetails();
      _checkRootStatus();
    });
  }

  void _initializeDeviceFeatures() {
    _deviceFeatures = [
      DeviceFeature(id: 'mobile_lock', name: AppStrings.mobileLock, icon: Icons.lock, isLocked: false),
      DeviceFeature(id: 'outgoing_call', name: AppStrings.outgoingCall, icon: Icons.phone, isLocked: false),
      DeviceFeature(id: 'camera', name: AppStrings.camera, icon: Icons.camera_alt, isLocked: false),
      DeviceFeature(id: 'setting', name: AppStrings.setting, icon: Icons.settings, isLocked: false),
      DeviceFeature(id: 'file_transfer', name: AppStrings.fileTransfer, icon: Icons.file_copy, isLocked: false),
      DeviceFeature(id: 'text_reminder', name: AppStrings.textReminder, icon: Icons.notifications, isLocked: false),
      DeviceFeature(id: 'device_location', name: AppStrings.getDeviceLocation, icon: Icons.location_on, isLocked: false),
      DeviceFeature(id: 'sim_details', name: AppStrings.getSimDetails, icon: Icons.sim_card, isLocked: false),
      DeviceFeature(id: 'offline_lock', name: AppStrings.offlineLock, icon: Icons.lock_clock, isLocked: false),
      DeviceFeature(id: 'unlock_code', name: AppStrings.unlockCode, icon: Icons.lock_open, isLocked: false),
      DeviceFeature(id: 'app_install', name: AppStrings.appInstall, icon: Icons.download, isLocked: false),
      DeviceFeature(id: 'app_uninstall', name: AppStrings.appUninstall, icon: Icons.delete, isLocked: false),
      DeviceFeature(id: 'hard_reset', name: AppStrings.hardReset, icon: Icons.refresh, isLocked: true),
      DeviceFeature(id: 'usb_debugging', name: AppStrings.usbDebugging, icon: Icons.usb, isLocked: true),
      DeviceFeature(id: 'audio_warning', name: AppStrings.audioWarning, icon: Icons.volume_up, isLocked: false),
    ];
  }

  void _initializeApps() {
    _apps = [
      AppControl(id: 'whatsapp', name: AppStrings.whatsapp, packageName: 'com.whatsapp', icon: Icons.chat, isLocked: false),
      AppControl(id: 'instagram', name: AppStrings.instagram, packageName: 'com.instagram.android', icon: Icons.camera_alt, isLocked: false),
      AppControl(id: 'snapchat', name: AppStrings.snapchat, packageName: 'com.snapchat.android', icon: Icons.camera, isLocked: false),
    ];
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Device & App Control Section
                  _buildDeviceControlSection(context),
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

  /// Build Device & App Control Section
  Widget _buildDeviceControlSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.deviceControl,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Device Control Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.deviceControlTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _deviceFeatures.length,
                    itemBuilder: (context, index) {
                      return _buildFeatureCard(context, _deviceFeatures[index]);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleRemoveKey,
                      icon: const Icon(Icons.key_off_rounded, size: 20),
                      label: Text(
                        AppStrings.removeKey,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // App Control Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.apps_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.appControlTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _apps.length,
                    itemBuilder: (context, index) {
                      return _buildAppCard(context, _apps[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Feature Card
  Widget _buildFeatureCard(BuildContext context, DeviceFeature feature) {
    final isLocked = feature.isLocked;
    final statusColor = isLocked 
        ? Theme.of(context).colorScheme.error 
        : const Color(0xFF10B981); // Green for unlocked
    final statusText = isLocked ? AppStrings.locked : AppStrings.unlocked;
    final bgColor = isLocked 
        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.05)
        : statusColor.withValues(alpha: 0.05);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFeatureToggle(feature),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: isLocked ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.icon,
                  size: 24,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  feature.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build App Card
  Widget _buildAppCard(BuildContext context, AppControl app) {
    final isLocked = app.isLocked;
    final statusColor = isLocked 
        ? Theme.of(context).colorScheme.error 
        : const Color(0xFF10B981); // Green for unlocked
    final statusText = isLocked ? AppStrings.locked : AppStrings.unlocked;
    final bgColor = isLocked 
        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.05)
        : statusColor.withValues(alpha: 0.05);

    // App-specific colors
    Color appIconColor = statusColor;
    if (!isLocked) {
      switch (app.id) {
        case 'whatsapp':
          appIconColor = const Color(0xFF25D366);
          break;
        case 'instagram':
          appIconColor = const Color(0xFFE4405F);
          break;
        case 'snapchat':
          appIconColor = const Color(0xFFFFFC00);
          break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleAppToggle(app),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: isLocked ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appIconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  app.icon,
                  size: 24,
                  color: appIconColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  app.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle Feature Toggle
  Future<void> _handleFeatureToggle(DeviceFeature feature) async {
    final newLockedState = !feature.isLocked;
    
    // Special handling for specific features
    if (feature.id == 'mobile_lock') {
      if (newLockedState) {
        final failure = await _deviceControlRepo.enableKioskMode();
        if (failure != null && mounted) {
          _showError(context, failure.message);
          return;
        }
      } else {
        final failure = await _deviceControlRepo.disableKioskMode();
        if (failure != null && mounted) {
          _showError(context, failure.message);
          return;
        }
      }
    } else if (feature.id == 'camera') {
      // Handle camera lock/unlock
      // This would require additional native implementation
    } else if (feature.id == 'hard_reset' || feature.id == 'usb_debugging') {
      // These are critical features - show warning
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${newLockedState ? 'Lock' : 'Unlock'} ${feature.name}'),
          content: Text('Are you sure you want to ${newLockedState ? 'lock' : 'unlock'} ${feature.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(newLockedState ? 'Lock' : 'Unlock'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    // Update feature state
    setState(() {
      final index = _deviceFeatures.indexWhere((f) => f.id == feature.id);
      if (index != -1) {
        _deviceFeatures[index] = feature.copyWith(isLocked: newLockedState);
      }
    });

    if (mounted) {
      _showSuccess(
        context,
        newLockedState ? AppStrings.featureLocked : AppStrings.featureUnlocked,
      );
    }
  }

  /// Handle App Toggle
  Future<void> _handleAppToggle(AppControl app) async {
    final newLockedState = !app.isLocked;

    // Update app state
    setState(() {
      final index = _apps.indexWhere((a) => a.id == app.id);
      if (index != -1) {
        _apps[index] = app.copyWith(isLocked: newLockedState);
      }
    });

    if (mounted) {
      _showSuccess(
        context,
        newLockedState ? AppStrings.appLocked : AppStrings.appUnlocked,
      );
    }
  }

  /// Handle Remove Key
  Future<void> _handleRemoveKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.removeKey),
        content: const Text('Are you sure you want to remove the key? This will unlock all features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Unlock all features
      setState(() {
        _deviceFeatures = _deviceFeatures.map((f) => f.copyWith(isLocked: false)).toList();
        _apps = _apps.map((a) => a.copyWith(isLocked: false)).toList();
      });

      // Disable kiosk mode
      await _deviceControlRepo.disableKioskMode();
      await _deviceControlRepo.allowScreenshot();

      if (mounted) {
        _showSuccess(context, 'All features unlocked');
      }
    }
  }

  /// Check Root Status
  Future<void> _checkRootStatus() async {
    if (_isCheckingRoot) return;

    setState(() {
      _isCheckingRoot = true;
    });

    try {
      final result = await _deviceControlRepo.checkRootAccess();
      if (mounted) {
        setState(() {
          _isCheckingRoot = false;
          if (result.failure != null) {
            _isRooted = null;
            _showError(context, result.failure!.message);
          } else {
            _isRooted = result.isRooted;
            if (_isRooted == true) {
              _showWarning(context, AppStrings.deviceRooted);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingRoot = false;
          _isRooted = null;
        });
        _showError(context, AppStrings.rootCheckFailed);
      }
    }
  }

  /// Show Success Message
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  /// Show Error Message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  /// Show Warning Message
  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }
}
