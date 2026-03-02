import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../../domain/use_cases/emi/check_emi_status_use_case.dart';
import '../../domain/use_cases/emi/get_emi_details_use_case.dart';
import '../viewmodels/locker_view_model.dart';
import 'lock_screen.dart';

/// Splash screen - checks EMI status and routes accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Dependency injection is already initialized in main.dart
    // Get repositories
    final authRepo = sl<AuthRepository>();
    final emiRepo = sl<EmiRepository>();
    final deviceControlRepo = sl<DeviceControlRepository>();

    // Check if user is logged in
    final isLoggedIn = await authRepo.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      // Navigate to login
      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      return;
    }

    // Check EMI status
    final lockerViewModel = LockerViewModel(
      CheckEmiStatusUseCase(emiRepo),
      GetEmiDetailsUseCase(emiRepo),
    );

    final isOverdue = await lockerViewModel.checkEmiStatus();

    if (!mounted) return;

    if (isOverdue) {
      // Enable kiosk mode and prevent screenshots
      await deviceControlRepo.enableKioskMode();
      await deviceControlRepo.preventScreenshot();

      // Navigate to lock screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: lockerViewModel,
              child: const LockScreen(),
            ),
          ),
        );
      }
    } else {
      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.dashboardRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
