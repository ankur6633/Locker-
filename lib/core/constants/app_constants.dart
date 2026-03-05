/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'https://api.emilocker.com';
  static const String wsUrl = 'wss://api.emilocker.com/ws';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String emiStatusKey = 'emi_status';
  static const String isLoggedInKey = 'is_logged_in';
  static const String loginEmailOrMobileKey = 'login_email_or_mobile';
  static const String userRoleKey = 'user_role'; // 'user' or 'admin'

  // Method Channel Names
  static const String deviceControlChannel = 'com.emilocker.device_control';
  static const String securityChannel = 'com.emilocker.security';

  // Method Names
  static const String enableKioskMode = 'enableKioskMode';
  static const String disableKioskMode = 'disableKioskMode';
  static const String lockDevice = 'lockDevice';
  static const String preventScreenshot = 'preventScreenshot';
  static const String allowScreenshot = 'allowScreenshot';
  static const String checkRootAccess = 'checkRootAccess';

  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String emiDetailsRoute = '/emi-details';
  static const String paymentHistoryRoute = '/payment-history';
  static const String emiScheduleRoute = '/emi-schedule';
  static const String lockScreenRoute = '/lock-screen';
  static const String paymentRoute = '/payment';
  static const String createMandateRoute = '/create-mandate';
  static const String mandateListRoute = '/mandate-list';
  static const String mandateDetailsRoute = '/mandate-details';
  static const String adminPanelRoute = '/admin-panel';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // EMI Status
  static const String emiStatusPaid = 'paid';
  static const String emiStatusPending = 'pending';
  static const String emiStatusOverdue = 'overdue';
  static const String emiStatusUpcoming = 'upcoming';
}
