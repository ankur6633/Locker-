# EMI Locker - Production-Grade Flutter Application

A scalable EMI Locker mobile application with enterprise-level architecture and device control capabilities.

## 🏗️ Architecture

- **Clean Architecture** - Separation of concerns with clear layer boundaries
- **MVVM Pattern** - ViewModels manage UI state and business logic
- **Repository Pattern** - Abstraction layer for data sources
- **Dependency Injection** - Using GetIt for dependency management

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants and strings
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error handling
│   ├── theme/              # App theme configuration
│   └── utils/              # Utility functions
├── data/                   # Data layer
│   ├── datasources/        # Remote and local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── use_cases/          # Business logic use cases
└── presentation/           # Presentation layer
    ├── screens/            # UI screens
    ├── viewmodels/         # ViewModels
    └── widgets/            # Reusable widgets
```

## ✨ Features

### 1. Authentication
- Login screen with email/password validation
- Secure token storage using FlutterSecureStorage
- Auto-login support
- Session management

### 2. Dashboard
- Total amount display
- EMI amount overview
- Remaining amount tracking
- Next due date
- EMI status indicator
- Animated progress bar
- Pull-to-refresh

### 3. EMI Module
- **EMI Details Screen** - Complete EMI information
- **Payment History** - List of all payments
- **EMI Schedule** - Installment schedule with status

### 4. Locker Engine
- On app start, checks EMI status
- If overdue → redirects to Lock Screen
- Disables back navigation on lock screen
- Shows due details
- Pay button for immediate payment

### 5. Real-Time Updates
- Firebase Cloud Messaging integration ready
- WebSocket support for lock/unlock commands
- State persistence using Hive/SharedPreferences

### 6. Device Control (Android)
- **Kiosk Mode** - Using `lockTask()` API
- **Device Locking** - Lock device programmatically
- **Screenshot Prevention** - FLAG_SECURE implementation
- **Root Detection** - Checks for root access

### 7. Security
- Secure token storage
- Screenshot prevention
- Root detection
- Secure storage for sensitive data

### 8. UI/UX
- Material 3 design system
- Modern fintech design
- Responsive layout
- Smooth animations
- Custom theme configuration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.11.0 or higher)
- Android Studio / VS Code
- Android SDK (API 21+)
- Kotlin support

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd emilocker
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Demo Credentials
- Email: `test@example.com`
- Password: `password123`

## 🔧 Configuration

### Android Setup

#### Kiosk Mode
To enable kiosk mode functionality:

1. **Device Owner Mode** (Recommended for production):
   - Set the app as device owner using ADB:
   ```bash
   adb shell dpm set-device-owner com.example.emilocker/.DeviceAdminReceiver
   ```

2. **Lock Task Mode** (Alternative):
   - Go to Settings → Security → Device Admin Apps
   - Enable the app as a device admin
   - Set the app as a lock task app in device settings

#### Permissions
The app requires the following permissions (already configured in AndroidManifest.xml):
- `INTERNET` - For API calls
- `ACCESS_NETWORK_STATE` - Network state checking
- `BIND_DEVICE_ADMIN` - Device admin functionality
- `LOCK_TASK_MODE` - Kiosk mode

### API Configuration
Update `lib/core/constants/app_constants.dart` with your API endpoints:
```dart
static const String baseUrl = 'https://your-api-url.com';
static const String wsUrl = 'wss://your-api-url.com/ws';
```

## 📱 Screens

1. **Splash Screen** - Initializes app and checks EMI status
2. **Login Screen** - User authentication
3. **Dashboard** - EMI overview and quick actions
4. **EMI Details** - Complete EMI information
5. **Payment History** - Transaction history
6. **EMI Schedule** - Installment schedule
7. **Lock Screen** - Shown when EMI is overdue
8. **Payment Screen** - Payment processing

## 🏛️ Architecture Details

### Clean Architecture Layers

1. **Domain Layer** (Business Logic)
   - Entities: Pure business objects
   - Repositories: Interfaces for data access
   - Use Cases: Business logic operations

2. **Data Layer** (Data Management)
   - Models: Data transfer objects
   - Data Sources: Remote (API) and Local (Storage)
   - Repository Implementations: Concrete implementations

3. **Presentation Layer** (UI)
   - Screens: UI pages
   - ViewModels: State management
   - Widgets: Reusable UI components

### State Management
Using Provider for state management with MVVM pattern.

### Dependency Injection
Using GetIt for dependency injection. All dependencies are registered in `lib/core/di/injection_container.dart`.

## 🔒 Security Features

1. **Secure Storage** - Tokens stored using FlutterSecureStorage
2. **Screenshot Prevention** - FLAG_SECURE on lock screen
3. **Root Detection** - Checks for root access
4. **Device Control** - Kiosk mode and device locking

## 🧪 Testing

The app includes mock data sources for development and testing:
- `AuthRemoteDataSourceMock` - Mock authentication
- `EmiRemoteDataSourceMock` - Mock EMI data

Switch to real API implementations in `lib/core/di/injection_container.dart` for production.

## 📝 Code Quality

- SOLID principles
- Clean code practices
- Comprehensive comments
- Scalable architecture
- Maintainable structure

## 🛠️ Technologies Used

- **Flutter** - UI framework
- **Provider** - State management
- **Dio** - HTTP client
- **Hive/SharedPreferences** - Local storage
- **FlutterSecureStorage** - Secure storage
- **Firebase** - Cloud messaging (ready for integration)
- **Material 3** - Design system

## 📄 License

This project is proprietary software.

## 👥 Contributing

This is a production-grade application. Follow the existing architecture patterns when adding new features.

## 📞 Support

For issues or questions, please contact the development team.
