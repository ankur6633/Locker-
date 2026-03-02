import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/emi_repository.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/dashboard_view_model.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/emi_details_screen.dart';
import 'presentation/screens/payment_history_screen.dart';
import 'presentation/screens/emi_schedule_screen.dart';
import 'presentation/screens/payment_screen.dart';
import 'presentation/screens/create_mandate_screen.dart';
import 'presentation/screens/mandate_list_screen.dart';
import 'admin/admin_app.dart';
import 'admin/services/admin_data_service.dart';
import 'admin/viewmodels/admin_dashboard_viewmodel.dart';
import 'admin/viewmodels/admin_users_viewmodel.dart';
import 'admin/viewmodels/admin_emi_viewmodel.dart';
import 'admin/screens/admin_main_screen.dart';
import 'domain/use_cases/auth/login_use_case.dart';
import 'domain/use_cases/auth/logout_use_case.dart';
import 'domain/use_cases/emi/get_emi_details_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await init();
  
  // Initialize admin data service
  final adminDataService = AdminDataService();
  await adminDataService.init();
  
  runApp(MyApp(adminDataService: adminDataService));
}

class MyApp extends StatelessWidget {
  final AdminDataService adminDataService;
  
  const MyApp({super.key, required this.adminDataService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            LoginUseCase(sl<AuthRepository>()),
            LogoutUseCase(sl<AuthRepository>()),
          ),
        ),
        // Dashboard ViewModel
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            GetEmiDetailsUseCase(sl<EmiRepository>()),
          ),
        ),
        // Admin ViewModels
        ChangeNotifierProvider(
          create: (_) => AdminDashboardViewModel(adminDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminUsersViewModel(adminDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminEmiViewModel(adminDataService),
        ),
      ],
      child: MaterialApp(
        title: 'EMI Locker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (_) => const SplashScreen(),
          AppConstants.loginRoute: (_) => const LoginScreen(),
          AppConstants.dashboardRoute: (_) => const DashboardScreen(),
          AppConstants.emiDetailsRoute: (_) => const EmiDetailsScreen(),
          AppConstants.paymentHistoryRoute: (_) => const PaymentHistoryScreen(),
          AppConstants.emiScheduleRoute: (_) => const EmiScheduleScreen(),
          AppConstants.createMandateRoute: (_) => const CreateMandateScreen(),
          AppConstants.mandateListRoute: (_) => const MandateListScreen(),
          AppConstants.adminPanelRoute: (_) => const AdminMainScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppConstants.paymentRoute) {
            return MaterialPageRoute(
              builder: (_) => PaymentScreen(emi: settings.arguments as dynamic),
            );
          }
          return null;
        },
      ),
    );
  }
}
