/// Application strings for internationalization support
class AppStrings {
  AppStrings._();

  // Common
  static const String appName = 'EMI Locker';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String logout = 'Logout';

  // Authentication
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String enterEmail = 'Enter your email';
  static const String enterPassword = 'Enter your password';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed. Please try again.';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalAmount = 'Total Amount';
  static const String emiAmount = 'EMI Amount';
  static const String remainingAmount = 'Remaining Amount';
  static const String nextDueDate = 'Next Due Date';
  static const String emiStatus = 'EMI Status';
  static const String viewDetails = 'View Details';
  static const String paymentHistory = 'Payment History';
  static const String emiSchedule = 'EMI Schedule';
  static const String paid = 'Paid';
  static const String adminPanel = 'Admin Panel';
  static const String openAdminPanel = 'Open Admin Panel';

  // EMI Details
  static const String emiDetails = 'EMI Details';
  static const String principalAmount = 'Principal Amount';
  static const String interestAmount = 'Interest Amount';
  static const String totalEmiAmount = 'Total EMI Amount';
  static const String emiTenure = 'EMI Tenure';
  static const String emiStartDate = 'EMI Start Date';
  static const String emiEndDate = 'EMI End Date';
  static const String monthlyEmi = 'Monthly EMI';

  // Payment
  static const String payNow = 'Pay Now';
  static const String paymentSuccess = 'Payment successful';
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String processingPayment = 'Processing payment...';
  
  // Mandate
  static const String createMandate = 'Create New Mandate';
  static const String mandate = 'Mandate';
  static const String mandates = 'Mandates';
  static const String mandateDetails = 'Mandate Details';
  static const String mandateAmount = 'Mandate Amount';
  static const String frequency = 'Frequency';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String paymentMethod = 'Payment Method';
  static const String bankAccount = 'Bank Account';
  static const String upi = 'UPI';
  static const String card = 'Card';
  static const String wallet = 'Wallet';
  static const String accountNumber = 'Account Number';
  static const String ifscCode = 'IFSC Code';
  static const String upiId = 'UPI ID';
  static const String cardNumber = 'Card Number';
  static const String cardHolderName = 'Card Holder Name';
  static const String expiryDate = 'Expiry Date';
  static const String cvv = 'CVV';
  static const String maxAmount = 'Max Amount';
  static const String maxDebits = 'Max Debits';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String quarterly = 'Quarterly';
  static const String yearly = 'Yearly';
  static const String active = 'Active';
  static const String paused = 'Paused';
  static const String cancelled = 'Cancelled';
  static const String expired = 'Expired';
  static const String pending = 'Pending';
  static const String createMandateSuccess = 'Mandate created successfully';
  static const String createMandateFailed = 'Failed to create mandate';
  static const String pauseMandate = 'Pause Mandate';
  static const String resumeMandate = 'Resume Mandate';
  static const String cancelMandate = 'Cancel Mandate';
  static const String mandatePaused = 'Mandate paused';
  static const String mandateResumed = 'Mandate resumed';
  static const String mandateCancelled = 'Mandate cancelled';
  static const String nextDebitDate = 'Next Debit Date';
  static const String debitCount = 'Debit Count';

  // Lock Screen
  static const String deviceLocked = 'Device Locked';
  static const String emiOverdue = 'EMI Overdue';
  static const String overdueMessage = 'Your EMI payment is overdue. Please make the payment to unlock your device.';
  static const String dueAmount = 'Due Amount';
  static const String daysOverdue = 'Days Overdue';

  // Device Control
  static const String deviceControl = 'Device & App Control';
  static const String deviceControlTitle = 'Device Control';
  static const String appControlTitle = 'App Control';
  static const String unlocked = 'UNLOCKED';
  static const String locked = 'LOCKED';
  static const String removeKey = 'Remove key';
  
  // Device Control Features
  static const String mobileLock = 'Mobile Lock';
  static const String outgoingCall = 'Outgoing call';
  static const String camera = 'Camera';
  static const String setting = 'Setting';
  static const String fileTransfer = 'File transfer';
  static const String textReminder = 'Text Reminder';
  static const String getDeviceLocation = 'Get device location';
  static const String getSimDetails = 'Get sim details';
  static const String offlineLock = 'Offline lock';
  static const String unlockCode = 'Unlock code';
  static const String appInstall = 'App install';
  static const String appUninstall = 'App Uninstall';
  static const String hardReset = 'Hard reset';
  static const String usbDebugging = 'USB debugging';
  static const String audioWarning = 'Audio warning';
  
  // App Control
  static const String whatsapp = 'WhatsApp';
  static const String instagram = 'Instagram';
  static const String snapchat = 'Snapchat';
  
  // Status Messages
  static const String featureLocked = 'Feature locked';
  static const String featureUnlocked = 'Feature unlocked';
  static const String appLocked = 'App locked';
  static const String appUnlocked = 'App unlocked';
  
  // Root Detection
  static const String rootDetection = 'Root Detection';
  static const String checkRootStatus = 'Check Root Status';
  static const String deviceRooted = 'Device is rooted';
  static const String deviceNotRooted = 'Device is not rooted';
  static const String rootCheckFailed = 'Failed to check root status';

  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String sessionExpired = 'Session expired. Please login again.';
}
