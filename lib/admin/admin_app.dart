import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import 'viewmodels/admin_dashboard_viewmodel.dart';
import 'viewmodels/admin_users_viewmodel.dart';
import 'viewmodels/admin_emi_viewmodel.dart';
import 'services/admin_data_service.dart';
import 'screens/admin_main_screen.dart';

/// Admin Panel Application
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a single instance of AdminDataService
    final dataService = AdminDataService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminDashboardViewModel(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminUsersViewModel(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminEmiViewModel(dataService),
        ),
      ],
      child: MaterialApp(
        title: 'EMI Locker Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AdminMainScreen(),
      ),
    );
  }
}
